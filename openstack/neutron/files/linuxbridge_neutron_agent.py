#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright 2012 Cisco Systems, Inc.
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
#
# Performs per host Linux Bridge configuration for Neutron.
# Based on the structure of the OpenVSwitch agent in the
# Neutron OpenVSwitch Plugin.
# @author: Sumit Naiksatam, Cisco Systems, Inc.

import os
import sys
import time

import eventlet
from oslo.config import cfg

from neutron.agent import l2population_rpc as l2pop_rpc
from neutron.agent.linux import ip_lib
from neutron.agent.linux import utils
from neutron.agent import rpc as agent_rpc
from neutron.agent import securitygroups_rpc as sg_rpc
from neutron.common import config as logging_config
from neutron.common import constants
from neutron.common import exceptions
from neutron.common import topics
from neutron.common import utils as q_utils
from neutron import context
from neutron.openstack.common import log as logging
from neutron.openstack.common import loopingcall
from neutron.openstack.common.rpc import common as rpc_common
from neutron.openstack.common.rpc import dispatcher
from neutron.plugins.common import constants as p_const
from neutron.plugins.linuxbridge.common import config  # noqa
from neutron.plugins.linuxbridge.common import constants as lconst
from neutron.agent.linux import utils
from neutron.agent.linux import interface


LOG = logging.getLogger(__name__)

BRIDGE_NAME_PREFIX = "brq"
TAP_INTERFACE_PREFIX = "tap"
BRIDGE_FS = "/sys/class/net/"
BRIDGE_NAME_PLACEHOLDER = "bridge_name"
BRIDGE_INTERFACES_FS = BRIDGE_FS + BRIDGE_NAME_PLACEHOLDER + "/brif/"
DEVICE_NAME_PLACEHOLDER = "device_name"
BRIDGE_PORT_FS_FOR_DEVICE = BRIDGE_FS + DEVICE_NAME_PLACEHOLDER + "/brport"
BRIDGE_FS_FOR_DEVICE = BRIDGE_PORT_FS_FOR_DEVICE + "/bridge"
VXLAN_INTERFACE_PREFIX = "vxlan-"
# Allow forwarding of all 802.1d reserved frames but 0 and disallowed STP, LLDP
BRIDGE_FWD_MASK_FS = BRIDGE_FS + BRIDGE_NAME_PLACEHOLDER + "/bridge/group_fwd_mask"
BRIDGE_FWD_MASK = hex(0xffff ^ (1 << 0x0 | 1 << 0x1 | 1 << 0x2 | 1 << 0xe))
BRIDGE_FWD_MASK_ALL = hex(0xffff)
# Check that instance exists before trying to execute virsh on it
NOVA_INSTANCE_DIR = '/var/lib/nova/instances/%s'


class NetworkSegment:
    def __init__(self, network_type, physical_network, segmentation_id):
        self.network_type = network_type
        self.physical_network = physical_network
        self.segmentation_id = segmentation_id


class LinuxBridgeManager:
    def __init__(self, interface_mappings, root_helper):
        self.interface_mappings = interface_mappings
        self.root_helper = root_helper
        self.ip = ip_lib.IPWrapper(self.root_helper)
        # VXLAN related parameters:
        self.local_ip = cfg.CONF.VXLAN.local_ip
        self.vxlan_mode = lconst.VXLAN_NONE
        if cfg.CONF.VXLAN.enable_vxlan:
            self.local_int = self.get_interface_by_ip(self.local_ip)
            if self.local_int:
                self.check_vxlan_support()
            else:
                LOG.warning(_('VXLAN is enabled, a valid local_ip '
                              'must be provided'))
        # Store network mapping to segments
        self.network_map = {}
        self.bridge_fwd_mask = BRIDGE_FWD_MASK_ALL

    def get_bridge_name(self, network_id):
        if not network_id:
            LOG.warning(_("Invalid Network ID, will lead to incorrect bridge"
                          "name"))
        bridge_name = BRIDGE_NAME_PREFIX + network_id[0:11]
        return bridge_name

    def get_subinterface_name(self, physical_interface, vlan_id):
        if not vlan_id:
            LOG.warning(_("Invalid VLAN ID, will lead to incorrect "
                          "subinterface name"))
        subinterface_name = '%s.%s' % (physical_interface, vlan_id)
        return subinterface_name

    def get_tap_device_name(self, interface_id):
        if not interface_id:
            LOG.warning(_("Invalid Interface ID, will lead to incorrect "
                          "tap device name"))
        tap_device_name = TAP_INTERFACE_PREFIX + interface_id[0:11]
        return tap_device_name

    def get_vxlan_device_name(self, segmentation_id):
        if 0 <= int(segmentation_id) <= constants.MAX_VXLAN_VNI:
            return VXLAN_INTERFACE_PREFIX + str(segmentation_id)
        else:
            LOG.warning(_("Invalid Segmentation ID: %s, will lead to "
                          "incorrect vxlan device name"), segmentation_id)

    def get_all_neutron_bridges(self):
        neutron_bridge_list = []
        bridge_list = os.listdir(BRIDGE_FS)
        for bridge in bridge_list:
            if bridge.startswith(BRIDGE_NAME_PREFIX):
                neutron_bridge_list.append(bridge)
        return neutron_bridge_list

    def device_exists(self, device):
        return os.path.exists(BRIDGE_FS + device)

    def get_interfaces_on_bridge(self, bridge_name):
        if self.device_exists(bridge_name):
            bridge_interface_path = BRIDGE_INTERFACES_FS.replace(
                BRIDGE_NAME_PLACEHOLDER, bridge_name)
            return os.listdir(bridge_interface_path)
        else:
            return []

    def get_tap_devices_count(self, bridge_name):
            bridge_interface_path = BRIDGE_INTERFACES_FS.replace(
                BRIDGE_NAME_PLACEHOLDER, bridge_name)
            try:
                if_list = os.listdir(bridge_interface_path)
                return len([interface for interface in if_list if
                            interface.startswith(TAP_INTERFACE_PREFIX)])
            except OSError:
                return 0

    def get_interface_by_ip(self, ip):
        for device in self.ip.get_devices():
            if device.addr.list(to=ip):
                return device.name

    def get_bridge_for_device(self, device_name):
        try:
            bridge_link_path = BRIDGE_FS_FOR_DEVICE.replace(
                DEVICE_NAME_PLACEHOLDER, device_name)
            return os.path.basename(os.readlink(bridge_link_path))
        except OSError:
            return None

    def is_device_on_bridge(self, device_name):
        if not device_name:
            return False
        else:
            bridge_port_path = BRIDGE_PORT_FS_FOR_DEVICE.replace(
                DEVICE_NAME_PLACEHOLDER, device_name)
            return os.path.exists(bridge_port_path)

    def ensure_vlan_bridge(self, network_id, physical_interface, vlan_id):
        """Create a vlan and bridge unless they already exist."""
        interface = self.ensure_vlan(physical_interface, vlan_id)
        bridge_name = self.get_bridge_name(network_id)
        ips, gateway = self.get_interface_details(interface)
        if self.ensure_bridge(bridge_name, interface, ips, gateway):
            return interface

    def ensure_vxlan_bridge(self, network_id, segmentation_id):
        """Create a vxlan and bridge unless they already exist."""
        interface = self.ensure_vxlan(segmentation_id)
        if not interface:
            LOG.error(_("Failed creating vxlan interface for "
                        "%(segmentation_id)s"),
                      {segmentation_id: segmentation_id})
            return
        bridge_name = self.get_bridge_name(network_id)
        self.ensure_bridge(bridge_name, interface)
        return interface

    def get_interface_details(self, interface):
        device = self.ip.device(interface)
        ips = device.addr.list(scope='global')

        # Update default gateway if necessary
        gateway = device.route.get_gateway(scope='global')
        return ips, gateway

    def ensure_flat_bridge(self, network_id, physical_interface):
        """Create a non-vlan bridge unless it already exists."""
        bridge_name = self.get_bridge_name(network_id)
        ips, gateway = self.get_interface_details(physical_interface)
        if self.ensure_bridge(bridge_name, physical_interface, ips, gateway):
            return physical_interface

    def ensure_local_bridge(self, network_id):
        """Create a local bridge unless it already exists."""
        bridge_name = self.get_bridge_name(network_id)
        return self.ensure_bridge(bridge_name)

    def ensure_vlan(self, physical_interface, vlan_id):
        """Create a vlan unless it already exists."""
        interface = self.get_subinterface_name(physical_interface, vlan_id)
        if not self.device_exists(interface):
            LOG.debug(_("Creating subinterface %(interface)s for "
                        "VLAN %(vlan_id)s on interface "
                        "%(physical_interface)s"),
                      {'interface': interface, 'vlan_id': vlan_id,
                       'physical_interface': physical_interface})
            if utils.execute(['ip', 'link', 'add', 'link',
                              physical_interface,
                              'name', interface, 'type', 'vlan', 'id',
                              vlan_id], root_helper=self.root_helper):
                return
            if utils.execute(['ip', 'link', 'set',
                              interface, 'up'], root_helper=self.root_helper):
                return
            LOG.debug(_("Done creating subinterface %s"), interface)
        return interface

    def ensure_vxlan(self, segmentation_id):
        """Create a vxlan unless it already exists."""
        interface = self.get_vxlan_device_name(segmentation_id)
        if not self.device_exists(interface):
            LOG.debug(_("Creating vxlan interface %(interface)s for "
                        "VNI %(segmentation_id)s"),
                      {'interface': interface,
                       'segmentation_id': segmentation_id})
            args = {'dev': self.local_int}
            if self.vxlan_mode == lconst.VXLAN_MCAST:
                args['group'] = cfg.CONF.VXLAN.vxlan_group
            if cfg.CONF.VXLAN.ttl:
                args['ttl'] = cfg.CONF.VXLAN.ttl
            if cfg.CONF.VXLAN.tos:
                args['tos'] = cfg.CONF.VXLAN.tos
            if cfg.CONF.VXLAN.l2_population:
                args['proxy'] = True
            if cfg.CONF.network_device_mtu:
                args['mtu'] = int(cfg.CONF.network_device_mtu)
            int_vxlan = self.ip.add_vxlan(interface, segmentation_id, **args)
            int_vxlan.link.set_up()
            LOG.debug(_("Done creating vxlan interface %s"), interface)
        return interface

    def update_interface_ip_details(self, destination, source, ips,
                                    gateway):
        if ips or gateway:
            dst_device = self.ip.device(destination)
            src_device = self.ip.device(source)

            dst_ips, dst_gw = self.get_interface_details(destination)
            src_ips, src_gw = self.get_interface_details(source)

        # Append IP's to bridge if necessary
        if ips:
            for ip in ips:
                if ip in dst_ips:
                    continue
                dst_device.addr.add(ip_version=ip['ip_version'],
                                    cidr=ip['cidr'],
                                    broadcast=ip['broadcast'])

        if gateway:
            # Ensure that the gateway can be updated by changing the metric
            metric = 100
            if 'metric' in gateway:
                metric = gateway['metric'] - 1
            if gateway != dst_gw:
                dst_device.route.add_gateway(gateway=gateway['gateway'],
                                             metric=metric)
            if gateway == src_gw:
                src_device.route.delete_gateway(gateway=gateway['gateway'])

        # Remove IP's from interface
        if ips:
            for ip in ips:
                if ip not in src_ips:
                    continue
                src_device.addr.delete(ip_version=ip['ip_version'],
                                       cidr=ip['cidr'])

    def ensure_bridge(self, bridge_name, interface=None, ips=None,
                      gateway=None):
        """Create a bridge unless it already exists."""
        if not self.device_exists(bridge_name):
            LOG.debug(_("Starting bridge %(bridge_name)s for subinterface "
                        "%(interface)s"),
                      {'bridge_name': bridge_name, 'interface': interface})
            if utils.execute(['brctl', 'addbr', bridge_name],
                             root_helper=self.root_helper):
                return
            if utils.execute(['brctl', 'setfd', bridge_name,
                              str(0)], root_helper=self.root_helper):
                return
            if utils.execute(['brctl', 'stp', bridge_name, 'off'],
                             root_helper=self.root_helper):
                LOG.warning('Failed to disable STP on bridge %s', bridge_name)
            if utils.execute(['ip', 'link', 'set', bridge_name,
                              'up'], root_helper=self.root_helper):
                return
            LOG.debug(_("Done starting bridge %(bridge_name)s for "
                        "subinterface %(interface)s"),
                      {'bridge_name': bridge_name, 'interface': interface})

        self.set_bridge_group_fwd_mask(bridge_name)

        if not interface:
            return bridge_name

        # Update IP info if necessary
        self.update_interface_ip_details(bridge_name, interface, ips, gateway)

        # Check if the interface is part of the bridge
        bridge = self.get_bridge_for_device(interface)
        if bridge != bridge_name:
            try:
                # Check if the interface is not enslaved in another bridge
                if bridge is not None:
                    utils.execute(['brctl', 'delif', bridge, interface],
                                  root_helper=self.root_helper)

                utils.execute(['brctl', 'addif', bridge_name, interface],
                              root_helper=self.root_helper)
            except Exception as e:
                LOG.error(_("Unable to add %(interface)s to %(bridge_name)s! "
                            "Exception: %(e)s"),
                          {'interface': interface, 'bridge_name': bridge_name,
                           'e': e})
                return
        return bridge_name

    def ensure_physical_in_bridge(self, network_id,
                                  network_type,
                                  physical_network,
                                  segmentation_id):
        if network_type == p_const.TYPE_VXLAN:
            if self.vxlan_mode == lconst.VXLAN_NONE:
                LOG.error(_("Unable to add vxlan interface for network %s"),
                          network_id)
                return
            return self.ensure_vxlan_bridge(network_id, segmentation_id)

        physical_interface = self.interface_mappings.get(physical_network)
        if not physical_interface:
            LOG.error(_("No mapping for physical network %s"),
                      physical_network)
            return
        if network_type == p_const.TYPE_FLAT:
            return self.ensure_flat_bridge(network_id, physical_interface)
        elif network_type == p_const.TYPE_VLAN:
            return self.ensure_vlan_bridge(network_id, physical_interface,
                                           segmentation_id)
        else:
            LOG.error(_("Unknown network_type %(network_type)s for network "
                        "%(network_id)s."), {network_type: network_type,
                                             network_id: network_id})

    def add_tap_interface(self, network_id, network_type, physical_network,
                          segmentation_id, tap_device_name):
        """Add tap interface.

        If a VIF has been plugged into a network, this function will
        add the corresponding tap device to the relevant bridge.
        """
        if not self.device_exists(tap_device_name):
            LOG.debug(_("Tap device: %s does not exist on "
                        "this host, skipped"), tap_device_name)
            return False

        bridge_name = self.get_bridge_name(network_id)
        if network_type == p_const.TYPE_LOCAL:
            self.ensure_local_bridge(network_id)
        elif not self.ensure_physical_in_bridge(network_id,
                                                network_type,
                                                physical_network,
                                                segmentation_id):
            return False

        # fix-neutron-agent-for-mtu-config hack
        LOG.debug(_("Set MTU Of %s"), tap_device_name)
        utils.execute(['ip', 'link', 'set' , tap_device_name, 'mtu', cfg.CONF.network_device_mtu],
                              root_helper=self.root_helper)
        # Check if device needs to be added to bridge
        in_bridge = self.get_bridge_for_device(tap_device_name)
        if in_bridge != bridge_name:
            data = {'tap_device_name': tap_device_name,
                    'bridge_name': bridge_name}
            msg = _("Adding device %(tap_device_name)s to bridge "
                    "%(bridge_name)s") % data
            LOG.debug(msg)
            if in_bridge and utils.execute(['brctl', 'delif', in_bridge, tap_device_name],
                                           root_helper=self.root_helper):
                return False
            if utils.execute(['brctl', 'addif', bridge_name, tap_device_name],
                             root_helper=self.root_helper):
                return False
        else:
            data = {'tap_device_name': tap_device_name,
                    'bridge_name': bridge_name}
            msg = _("%(tap_device_name)s already exists on bridge "
                    "%(bridge_name)s") % data
            LOG.debug(msg)
        return True

    def add_interface(self, network_id, network_type, physical_network,
                      segmentation_id, port_id):
        self.network_map[network_id] = NetworkSegment(network_type,
                                                      physical_network,
                                                      segmentation_id)
        tap_device_name = self.get_tap_device_name(port_id)
        return self.add_tap_interface(network_id, network_type,
                                      physical_network, segmentation_id,
                                      tap_device_name)

    def delete_vlan_bridge(self, bridge_name):
        if self.device_exists(bridge_name):
            interfaces_on_bridge = self.get_interfaces_on_bridge(bridge_name)
            for interface in interfaces_on_bridge:
                self.remove_interface(bridge_name, interface)

                if interface.startswith(VXLAN_INTERFACE_PREFIX):
                    self.delete_vxlan(interface)
                    continue

                for physical_interface in self.interface_mappings.itervalues():
                    if (interface.startswith(physical_interface)):
                        ips, gateway = self.get_interface_details(bridge_name)
                        if ips:
                            # This is a flat network or a VLAN interface that
                            # was setup outside of neutron => return IP's from
                            # bridge to interface
                            self.update_interface_ip_details(interface,
                                                             bridge_name,
                                                             ips, gateway)
                        elif physical_interface != interface:
                            self.delete_vlan(interface)

            LOG.debug(_("Deleting bridge %s"), bridge_name)
            if utils.execute(['ip', 'link', 'set', bridge_name, 'down'],
                             root_helper=self.root_helper):
                return
            if utils.execute(['brctl', 'delbr', bridge_name],
                             root_helper=self.root_helper):
                return
            LOG.debug(_("Done deleting bridge %s"), bridge_name)

        else:
            LOG.error(_("Cannot delete bridge %s, does not exist"),
                      bridge_name)

    def remove_empty_bridges(self):
        for network_id in self.network_map.keys():
            bridge_name = self.get_bridge_name(network_id)
            if not self.get_tap_devices_count(bridge_name):
                self.delete_vlan_bridge(bridge_name)
                del self.network_map[network_id]

    def remove_interface(self, bridge_name, interface_name):
        if self.device_exists(bridge_name):
            if not self.is_device_on_bridge(interface_name):
                return True
            LOG.debug(_("Removing device %(interface_name)s from bridge "
                        "%(bridge_name)s"),
                      {'interface_name': interface_name,
                       'bridge_name': bridge_name})
            if utils.execute(['brctl', 'delif', bridge_name, interface_name],
                             root_helper=self.root_helper):
                return False
            LOG.debug(_("Done removing device %(interface_name)s from bridge "
                        "%(bridge_name)s"),
                      {'interface_name': interface_name,
                       'bridge_name': bridge_name})
            return True
        else:
            LOG.debug(_("Cannot remove device %(interface_name)s bridge "
                        "%(bridge_name)s does not exist"),
                      {'interface_name': interface_name,
                       'bridge_name': bridge_name})
            return False

    def delete_vlan(self, interface):
        if self.device_exists(interface):
            LOG.debug(_("Deleting subinterface %s for vlan"), interface)
            if utils.execute(['ip', 'link', 'set', interface, 'down'],
                             root_helper=self.root_helper):
                return
            if utils.execute(['ip', 'link', 'delete', interface],
                             root_helper=self.root_helper):
                return
            LOG.debug(_("Done deleting subinterface %s"), interface)

    def delete_vxlan(self, interface):
        if self.device_exists(interface):
            LOG.debug(_("Deleting vxlan interface %s for vlan"),
                      interface)
            int_vxlan = self.ip.device(interface)
            int_vxlan.link.set_down()
            int_vxlan.link.delete()
            LOG.debug(_("Done deleting vxlan interface %s"), interface)

    def update_device_link(self, port_id, dom_id, hw_addr, owner, state):
        """Set link state of interface based on admin state in libvirt/kvm"""
        if not owner or not owner.startswith('compute:'):
            return None
        if not hw_addr or not dom_id:
            return False
        if not os.path.isdir(NOVA_INSTANCE_DIR % dom_id):
            LOG.warning('Cannot update device %s link %s on missing domain %s',
                        port_id, hw_addr, dom_id)
            return None

        state = 'up' if state else 'down'
        LOG.debug('Bringing port %s with %s of domain %s %s',
                  port_id, hw_addr, dom_id, state)
        try:
            utils.execute(['virsh', 'domif-setlink', '--domain', dom_id,
                           '--interface', hw_addr, '--state', state],
                          root_helper=self.root_helper)
            return True
        except RuntimeError:
            LOG.exception('Failed to update port %s of domain %s mac %s to %s',
                          port_id, dom_id, hw_addr, state)
            return False

    def set_bridge_group_fwd_mask(self, bridge_name):
        """Set bridge group_fwd_mask to let reserved multicast frames through"""

        # Forward all available multicast frames prohibited by 802.1d
        bridge_mask_path = BRIDGE_FWD_MASK_FS.replace(
                               BRIDGE_NAME_PLACEHOLDER, bridge_name)
        try:
            utils.execute(['tee', bridge_mask_path],
                          process_input=self.bridge_fwd_mask,
                          root_helper=self.root_helper)
        except RuntimeError:
            if self.bridge_fwd_mask == BRIDGE_FWD_MASK_ALL:
                LOG.warning('Cannot unmask all mcast forwarding on bridge %s',
                            bridge_name)
                LOG.warning('Some frames (LACP, LLDP) will be dropped')
                self.bridge_fwd_mask = BRIDGE_FWD_MASK
                self.set_bridge_group_fwd_mask(bridge_name)
            else:
                LOG.error('Cannot unmask any mcast forwarding on bridge %s',
                          bridge_name)

    def update_devices(self, registered_devices):
        devices = self.get_tap_devices()
        if devices == registered_devices:
            return
        added = devices - registered_devices
        removed = registered_devices - devices
        return {'current': devices,
                'added': added,
                'removed': removed}

    def get_tap_devices(self):
        devices = set()
        for device in os.listdir(BRIDGE_FS):
            if device.startswith(TAP_INTERFACE_PREFIX):
                devices.add(device)
        return devices

    def vxlan_ucast_supported(self):
        if not cfg.CONF.VXLAN.l2_population:
            return False
        if not ip_lib.iproute_arg_supported(
                ['bridge', 'fdb'], 'append', self.root_helper):
            LOG.warning(_('Option "%(option)s" must be supported by command '
                          '"%(command)s" to enable %(mode)s mode') %
                        {'option': 'append',
                         'command': 'bridge fdb',
                         'mode': 'VXLAN UCAST'})
            return False
        for segmentation_id in range(1, constants.MAX_VXLAN_VNI + 1):
            if not self.device_exists(
                    self.get_vxlan_device_name(segmentation_id)):
                break
        else:
            LOG.error(_('No valid Segmentation ID to perform UCAST test.'))
            return False

        test_iface = self.ensure_vxlan(segmentation_id)
        try:
            utils.execute(
                cmd=['bridge', 'fdb', 'append', constants.FLOODING_ENTRY[0],
                     'dev', test_iface, 'dst', '1.1.1.1'],
                root_helper=self.root_helper)
            return True
        except RuntimeError:
            return False
        finally:
            self.delete_vxlan(test_iface)

    def vxlan_mcast_supported(self):
        if not cfg.CONF.VXLAN.vxlan_group:
            LOG.warning(_('VXLAN muticast group must be provided in '
                          'vxlan_group option to enable VXLAN MCAST mode'))
            return False
        if not ip_lib.iproute_arg_supported(
                ['ip', 'link', 'add', 'type', 'vxlan'],
                'proxy', self.root_helper):
            LOG.warning(_('Option "%(option)s" must be supported by command '
                          '"%(command)s" to enable %(mode)s mode') %
                        {'option': 'proxy',
                         'command': 'ip link add type vxlan',
                         'mode': 'VXLAN MCAST'})

            return False
        return True

    def vxlan_module_supported(self):
        try:
            utils.execute(cmd=['modinfo', 'vxlan'])
            return True
        except RuntimeError:
            return False

    def check_vxlan_support(self):
        self.vxlan_mode = lconst.VXLAN_NONE
        if not self.vxlan_module_supported():
            LOG.error(_('Linux kernel vxlan module and iproute2 3.8 or above '
                        'are required to enable VXLAN.'))
            raise exceptions.VxlanNetworkUnsupported()

        if self.vxlan_ucast_supported():
            self.vxlan_mode = lconst.VXLAN_UCAST
        elif self.vxlan_mcast_supported():
            self.vxlan_mode = lconst.VXLAN_MCAST
        else:
            raise exceptions.VxlanNetworkUnsupported()
        LOG.debug(_('Using %s VXLAN mode'), self.vxlan_mode)

    def fdb_ip_entry_exists(self, mac, ip, interface):
        entries = utils.execute(['ip', 'neigh', 'show', 'to', ip,
                                 'dev', interface],
                                root_helper=self.root_helper)
        return mac in entries

    def fdb_bridge_entry_exists(self, mac, interface, agent_ip=None):
        entries = utils.execute(['bridge', 'fdb', 'show', 'dev', interface],
                                root_helper=self.root_helper)
        if not agent_ip:
            return mac in entries

        return (agent_ip in entries and mac in entries)

    def add_fdb_ip_entry(self, mac, ip, interface):
        utils.execute(['ip', 'neigh', 'replace', ip, 'lladdr', mac,
                       'dev', interface, 'nud', 'permanent'],
                      root_helper=self.root_helper,
                      check_exit_code=False)

    def remove_fdb_ip_entry(self, mac, ip, interface):
        utils.execute(['ip', 'neigh', 'del', ip, 'lladdr', mac,
                       'dev', interface],
                      root_helper=self.root_helper,
                      check_exit_code=False)

    def add_fdb_bridge_entry(self, mac, agent_ip, interface, operation="add"):
        utils.execute(['bridge', 'fdb', operation, mac, 'dev', interface,
                       'dst', agent_ip],
                      root_helper=self.root_helper,
                      check_exit_code=False)

    def remove_fdb_bridge_entry(self, mac, agent_ip, interface):
        utils.execute(['bridge', 'fdb', 'del', mac, 'dev', interface,
                       'dst', agent_ip],
                      root_helper=self.root_helper,
                      check_exit_code=False)

    def add_fdb_entries(self, agent_ip, ports, interface):
        for mac, ip in ports:
            if mac != constants.FLOODING_ENTRY[0]:
                self.add_fdb_ip_entry(mac, ip, interface)
                self.add_fdb_bridge_entry(mac, agent_ip, interface)
            elif self.vxlan_mode == lconst.VXLAN_UCAST:
                if self.fdb_bridge_entry_exists(mac, interface):
                    self.add_fdb_bridge_entry(mac, agent_ip, interface,
                                              "append")
                else:
                    self.add_fdb_bridge_entry(mac, agent_ip, interface)

    def remove_fdb_entries(self, agent_ip, ports, interface):
        for mac, ip in ports:
            if mac != constants.FLOODING_ENTRY[0]:
                self.remove_fdb_ip_entry(mac, ip, interface)
                self.remove_fdb_bridge_entry(mac, agent_ip, interface)
            elif self.vxlan_mode == lconst.VXLAN_UCAST:
                self.remove_fdb_bridge_entry(mac, agent_ip, interface)


class LinuxBridgeRpcCallbacks(sg_rpc.SecurityGroupAgentRpcCallbackMixin,
                              l2pop_rpc.L2populationRpcCallBackMixin):

    # Set RPC API version to 1.0 by default.
    # history
    #   1.1 Support Security Group RPC
    RPC_API_VERSION = '1.1'

    def __init__(self, context, agent):
        self.context = context
        self.agent = agent
        self.sg_agent = agent

    def network_delete(self, context, **kwargs):
        LOG.debug(_("network_delete received"))
        network_id = kwargs.get('network_id')
        bridge_name = self.agent.br_mgr.get_bridge_name(network_id)
        LOG.debug(_("Delete %s"), bridge_name)
        self.agent.br_mgr.delete_vlan_bridge(bridge_name)

    def port_update(self, context, **kwargs):
        LOG.debug(_("port_update received"))
        # Check port exists on node
        port = kwargs.get('port')
        tap_device_name = self.agent.br_mgr.get_tap_device_name(port['id'])
        devices = self.agent.br_mgr.get_tap_devices()
        if tap_device_name not in devices:
            return

        if 'security_groups' in port:
            self.sg_agent.refresh_firewall()
        try:
            LOG.debug('Update of port %s' % port)
            updown = self.agent.br_mgr.update_device_link(port_id=port['id'],
                                                          dom_id=port.get('device_id'),
                                                          hw_addr=port.get('mac_address'),
                                                          owner=port.get('device_owner'), 
                                                          state=port['admin_state_up'])
            if port['admin_state_up']:
                network_type = kwargs.get('network_type')
                if network_type:
                    segmentation_id = kwargs.get('segmentation_id')
                else:
                    # compatibility with pre-Havana RPC vlan_id encoding
                    vlan_id = kwargs.get('vlan_id')
                    (network_type,
                     segmentation_id) = lconst.interpret_vlan_id(vlan_id)
                physical_network = kwargs.get('physical_network')
                # create the networking for the port
                if self.agent.br_mgr.add_interface(port['network_id'],
                                                   network_type,
                                                   physical_network,
                                                   segmentation_id,
                                                   port['id']):
                    # update plugin about port status
                    self.agent.plugin_rpc.update_device_up(self.context,
                                                           tap_device_name,
                                                           self.agent.agent_id,
                                                           cfg.CONF.host)
                else:
                    self.agent.plugin_rpc.update_device_down(
                        self.context,
                        tap_device_name,
                        self.agent.agent_id,
                        cfg.CONF.host
                    )
            else:
                bridge_name = self.agent.br_mgr.get_bridge_name(
                    port['network_id'])
                self.agent.br_mgr.remove_interface(bridge_name,
                                                   tap_device_name)
                # update plugin about port status
                self.agent.plugin_rpc.update_device_down(self.context,
                                                         tap_device_name,
                                                         self.agent.agent_id,
                                                         cfg.CONF.host)
        except rpc_common.Timeout:
            LOG.error(_("RPC timeout while updating port %s"), port['id'])

    def fdb_add(self, context, fdb_entries):
        LOG.debug(_("fdb_add received"))
        for network_id, values in fdb_entries.items():
            segment = self.agent.br_mgr.network_map.get(network_id)
            if not segment:
                return

            if segment.network_type != p_const.TYPE_VXLAN:
                return

            interface = self.agent.br_mgr.get_vxlan_device_name(
                segment.segmentation_id)

            agent_ports = values.get('ports')
            for agent_ip, ports in agent_ports.items():
                if agent_ip == self.agent.br_mgr.local_ip:
                    continue

                self.agent.br_mgr.add_fdb_entries(agent_ip,
                                                  ports,
                                                  interface)

    def fdb_remove(self, context, fdb_entries):
        LOG.debug(_("fdb_remove received"))
        for network_id, values in fdb_entries.items():
            segment = self.agent.br_mgr.network_map.get(network_id)
            if not segment:
                return

            if segment.network_type != p_const.TYPE_VXLAN:
                return

            interface = self.agent.br_mgr.get_vxlan_device_name(
                segment.segmentation_id)

            agent_ports = values.get('ports')
            for agent_ip, ports in agent_ports.items():
                if agent_ip == self.agent.br_mgr.local_ip:
                    continue

                self.agent.br_mgr.remove_fdb_entries(agent_ip,
                                                     ports,
                                                     interface)

    def _fdb_chg_ip(self, context, fdb_entries):
        LOG.debug(_("update chg_ip received"))
        for network_id, agent_ports in fdb_entries.items():
            segment = self.agent.br_mgr.network_map.get(network_id)
            if not segment:
                return

            if segment.network_type != p_const.TYPE_VXLAN:
                return

            interface = self.agent.br_mgr.get_vxlan_device_name(
                segment.segmentation_id)

            for agent_ip, state in agent_ports.items():
                if agent_ip == self.agent.br_mgr.local_ip:
                    continue

                after = state.get('after')
                for mac, ip in after:
                    self.agent.br_mgr.add_fdb_ip_entry(mac, ip, interface)

                before = state.get('before')
                for mac, ip in before:
                    self.agent.br_mgr.remove_fdb_ip_entry(mac, ip, interface)

    def fdb_update(self, context, fdb_entries):
        LOG.debug(_("fdb_update received"))
        for action, values in fdb_entries.items():
            method = '_fdb_' + action
            if not hasattr(self, method):
                raise NotImplementedError()

            getattr(self, method)(context, values)

    def create_rpc_dispatcher(self):
        '''Get the rpc dispatcher for this manager.

        If a manager would like to set an rpc API version, or support more than
        one class as the target of rpc messages, override this method.
        '''
        return dispatcher.RpcDispatcher([self])


class LinuxBridgePluginApi(agent_rpc.PluginApi,
                           sg_rpc.SecurityGroupServerRpcApiMixin):
    pass


class LinuxBridgeNeutronAgentRPC(sg_rpc.SecurityGroupAgentRpcMixin):

    def __init__(self, interface_mappings, polling_interval,
                 root_helper):
        self.polling_interval = polling_interval
        self.root_helper = root_helper
        self.setup_linux_bridge(interface_mappings)
        configurations = {'interface_mappings': interface_mappings}
        if self.br_mgr.vxlan_mode != lconst.VXLAN_NONE:
            configurations['tunneling_ip'] = self.br_mgr.local_ip
            configurations['tunnel_types'] = [p_const.TYPE_VXLAN]
            configurations['l2_population'] = cfg.CONF.VXLAN.l2_population
        self.agent_state = {
            'binary': 'neutron-linuxbridge-agent',
            'host': cfg.CONF.host,
            'topic': constants.L2_AGENT_TOPIC,
            'configurations': configurations,
            'agent_type': constants.AGENT_TYPE_LINUXBRIDGE,
            'start_flag': True}

        self.setup_rpc(interface_mappings.values())
        self.init_firewall()

    def _report_state(self):
        try:
            devices = len(self.br_mgr.get_tap_devices())
            self.agent_state.get('configurations')['devices'] = devices
            self.state_rpc.report_state(self.context,
                                        self.agent_state)
            self.agent_state.pop('start_flag', None)
        except Exception:
            LOG.exception(_("Failed reporting state!"))

    def setup_rpc(self, physical_interfaces):
        if physical_interfaces:
            mac = utils.get_interface_mac(physical_interfaces[0])
        else:
            devices = ip_lib.IPWrapper(self.root_helper).get_devices(True)
            if devices:
                mac = utils.get_interface_mac(devices[0].name)
            else:
                LOG.error(_("Unable to obtain MAC address for unique ID. "
                            "Agent terminated!"))
                exit(1)
        self.agent_id = '%s%s' % ('lb', (mac.replace(":", "")))
        LOG.info(_("RPC agent_id: %s"), self.agent_id)

        self.topic = topics.AGENT
        self.plugin_rpc = LinuxBridgePluginApi(topics.PLUGIN)
        self.state_rpc = agent_rpc.PluginReportStateAPI(topics.PLUGIN)
        # RPC network init
        self.context = context.get_admin_context_without_session()
        # Handle updates from service
        self.callbacks = LinuxBridgeRpcCallbacks(self.context,
                                                 self)
        self.dispatcher = self.callbacks.create_rpc_dispatcher()
        # Define the listening consumers for the agent
        consumers = [[topics.PORT, topics.UPDATE],
                     [topics.NETWORK, topics.DELETE],
                     [topics.SECURITY_GROUP, topics.UPDATE]]
        if cfg.CONF.VXLAN.l2_population:
            consumers.append([topics.L2POPULATION,
                              topics.UPDATE, cfg.CONF.host])
        self.connection = agent_rpc.create_consumers(self.dispatcher,
                                                     self.topic,
                                                     consumers)
        report_interval = cfg.CONF.AGENT.report_interval
        if report_interval:
            heartbeat = loopingcall.FixedIntervalLoopingCall(
                self._report_state)
            heartbeat.start(interval=report_interval)

    def setup_linux_bridge(self, interface_mappings):
        self.br_mgr = LinuxBridgeManager(interface_mappings, self.root_helper)

    def remove_port_binding(self, network_id, interface_id):
        bridge_name = self.br_mgr.get_bridge_name(network_id)
        tap_device_name = self.br_mgr.get_tap_device_name(interface_id)
        return self.br_mgr.remove_interface(bridge_name, tap_device_name)

    def process_network_devices(self, device_info):
        resync_a = False
        resync_b = False
        if 'added' in device_info:
            resync_a = self.treat_devices_added(device_info['added'])
        if 'removed' in device_info:
            resync_b = self.treat_devices_removed(device_info['removed'])
        # If one of the above operations fails => resync with plugin
        return (resync_a | resync_b)

    def treat_devices_added(self, devices):
        resync = False
        self.prepare_devices_filter(devices)
        for device in devices:
            LOG.debug(_("Port %s added"), device)
            try:
                details = self.plugin_rpc.get_device_details(self.context,
                                                             device,
                                                             self.agent_id)
            except Exception as e:
                LOG.debug(_("Unable to get port details for "
                            "%(device)s: %(e)s"),
                          {'device': device, 'e': e})
                resync = True
                continue
            if 'port_id' in details:
                LOG.info(_("Port %(device)s updated. Details: %(details)s"),
                         {'device': device, 'details': details})
                updown = self.br_mgr.update_device_link(port_id=details['port_id'],
                                                        dom_id=details.get('device_id'),
                                                        hw_addr=details.get('mac_address'),
                                                        owner=details.get('device_owner'),
                                                        state=details['admin_state_up'])
                if details['admin_state_up']:
                    # create the networking for the port
                    network_type = details.get('network_type')
                    if network_type:
                        segmentation_id = details.get('segmentation_id')
                    else:
                        # compatibility with pre-Havana RPC vlan_id encoding
                        vlan_id = details.get('vlan_id')
                        (network_type,
                         segmentation_id) = lconst.interpret_vlan_id(vlan_id)
                    if self.br_mgr.add_interface(details['network_id'],
                                                 network_type,
                                                 details['physical_network'],
                                                 segmentation_id,
                                                 details['port_id']):

                        # update plugin about port status
                        self.plugin_rpc.update_device_up(self.context,
                                                         device,
                                                         self.agent_id,
                                                         cfg.CONF.host)
                    else:
                        self.plugin_rpc.update_device_down(self.context,
                                                           device,
                                                           self.agent_id,
                                                           cfg.CONF.host)
                else:
                    self.remove_port_binding(details['network_id'],
                                             details['port_id'])
            else:
                LOG.info(_("Device %s not defined on plugin"), device)
        return resync

    def treat_devices_removed(self, devices):
        resync = False
        self.remove_devices_filter(devices)
        for device in devices:
            LOG.info(_("Attachment %s removed"), device)
            try:
                details = self.plugin_rpc.update_device_down(self.context,
                                                             device,
                                                             self.agent_id,
                                                             cfg.CONF.host)
            except Exception as e:
                LOG.debug(_("port_removed failed for %(device)s: %(e)s"),
                          {'device': device, 'e': e})
                resync = True
            if details['exists']:
                LOG.info(_("Port %s updated."), device)
            else:
                LOG.debug(_("Device %s not defined on plugin"), device)
            self.br_mgr.remove_empty_bridges()
        return resync

    def daemon_loop(self):
        sync = True
        devices = set()

        LOG.info(_("LinuxBridge Agent RPC Daemon Started!"))

        while True:
            start = time.time()
            if sync:
                LOG.info(_("Agent out of sync with plugin!"))
                devices.clear()
                sync = False
            device_info = {}
            try:
                device_info = self.br_mgr.update_devices(devices)
            except Exception:
                LOG.exception(_("Update devices failed"))
                sync = True
            try:
                # notify plugin about device deltas
                if device_info:
                    LOG.debug(_("Agent loop has new devices!"))
                    # If treat devices fails - indicates must resync with
                    # plugin
                    sync = self.process_network_devices(device_info)
                    devices = device_info['current']
            except Exception:
                LOG.exception(_("Error in agent loop. Devices info: %s"),
                              device_info)
                sync = True
            # sleep till end of polling interval
            elapsed = (time.time() - start)
            if (elapsed < self.polling_interval):
                time.sleep(self.polling_interval - elapsed)
            else:
                LOG.debug(_("Loop iteration exceeded interval "
                            "(%(polling_interval)s vs. %(elapsed)s)!"),
                          {'polling_interval': self.polling_interval,
                           'elapsed': elapsed})


def main():
    eventlet.monkey_patch()
    cfg.CONF(project='neutron')

    # fix-neutron-agent-for-mtu-config hack
    cfg.CONF.register_opts(interface.OPTS)
    logging_config.setup_logging(cfg.CONF)
    LOG.info(_("network_device_mtu: %s"), str(cfg.CONF.network_device_mtu))
    try:
        interface_mappings = q_utils.parse_mappings(
            cfg.CONF.LINUX_BRIDGE.physical_interface_mappings)
    except ValueError as e:
        LOG.error(_("Parsing physical_interface_mappings failed: %s."
                    " Agent terminated!"), e)
        sys.exit(1)
    LOG.info(_("Interface mappings: %s"), interface_mappings)

    polling_interval = cfg.CONF.AGENT.polling_interval
    root_helper = cfg.CONF.AGENT.root_helper
    agent = LinuxBridgeNeutronAgentRPC(interface_mappings,
                                       polling_interval,
                                       root_helper)
    LOG.info(_("Agent initialized successfully, now running... "))
    agent.daemon_loop()
    sys.exit(0)


if __name__ == "__main__":
    main()
