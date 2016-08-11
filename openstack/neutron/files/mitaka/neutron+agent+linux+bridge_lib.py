# Copyright 2015 Intel Corporation.
# Copyright 2015 Isaku Yamahata <isaku.yamahata at intel com>
#                               <isaku.yamahata at gmail com>
# All Rights Reserved.
#
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

import os

from oslo_log import log as logging

from neutron.agent.common import utils
from neutron.agent.linux import ip_lib

LOG = logging.getLogger(__name__)

# NOTE(toabctl): Don't use /sys/devices/virtual/net here because not all tap
# devices are listed here (i.e. when using Xen)
BRIDGE_FS = "/sys/class/net/"
BRIDGE_INTERFACE_FS = BRIDGE_FS + "%(bridge)s/brif/%(interface)s"
BRIDGE_INTERFACES_FS = BRIDGE_FS + "%s/brif/"
BRIDGE_PORT_FS_FOR_DEVICE = BRIDGE_FS + "%s/brport"
BRIDGE_PATH_FOR_DEVICE = BRIDGE_PORT_FS_FOR_DEVICE + '/bridge'
# Bridge ageing control
BRIDGE_AGEING_FS = BRIDGE_FS + "%s/bridge/ageing_time"
# Bridge multicast snooping control
BRIDGE_SNOOPING_FS = BRIDGE_FS + "%s/bridge/multicast_snooping"
# Allow forwarding of all 802.1d reserved frames but 0 and disallowed STP, LLDP
BRIDGE_FWD_MASK_FS = BRIDGE_FS + "%s/bridge/group_fwd_mask"
BRIDGE_FWD_MASK = hex(0xffff ^ (1 << 0x0 | 1 << 0x1 | 1 << 0x2 | 1 << 0xe))
BRIDGE_FWD_MASK_ALL = hex(0xffff)


def is_bridged_interface(interface):
    if not interface:
        return False
    else:
        return os.path.exists(BRIDGE_PORT_FS_FOR_DEVICE % interface)


def get_interface_bridged_time(interface):
    try:
        return os.stat(BRIDGE_PORT_FS_FOR_DEVICE % interface).st_mtime
    except OSError:
        pass


def get_bridge_names():
    return os.listdir(BRIDGE_FS)


class BridgeDevice(ip_lib.IPDevice):
    def _brctl(self, cmd):
        cmd = ['brctl'] + cmd
        ip_wrapper = ip_lib.IPWrapper(self.namespace)
        return ip_wrapper.netns.execute(cmd, run_as_root=True)

    def _tee(self, path, inputs):
        cmd = ['tee', path % self.name]
        return utils.execute(cmd, process_input=str(inputs), run_as_root=True,
                             log_fail_as_error=self.log_fail_as_error)

    @classmethod
    def addbr(cls, name, namespace=None):
        bridge = cls(name, namespace)
        bridge._brctl(['addbr', bridge.name])
        return bridge

    @classmethod
    def get_interface_bridge(cls, interface):
        name = cls.get_interface_bridge_name(interface)
        if name is None:
            return None
        return cls(name)

    @staticmethod
    def get_interface_bridge_name(interface):
        try:
            path = os.readlink(BRIDGE_PATH_FOR_DEVICE % interface)
        except OSError:
            return None
        else:
            name = path.rpartition('/')[-1]
            return name

    def delbr(self):
        return self._brctl(['delbr', self.name])

    def addif(self, interface):
        return self._brctl(['addif', self.name, interface])

    def delif(self, interface):
        return self._brctl(['delif', self.name, interface])

    def setfd(self, fd):
        return self._brctl(['setfd', self.name, str(fd)])

    def disable_stp(self):
        return self._brctl(['stp', self.name, 'off'])

    def owns_interface(self, interface):
        return os.path.exists(
            BRIDGE_INTERFACE_FS % {'bridge': self.name,
                                   'interface': interface})

    def get_interfaces(self):
        try:
            return os.listdir(BRIDGE_INTERFACES_FS % self.name)
        except OSError:
            return []

    def set_group_fwd_mask(self, mask=BRIDGE_FWD_MASK_ALL):
        try:
            self._tee(BRIDGE_FWD_MASK_FS, mask)
        except RuntimeError:
            if mask == BRIDGE_FWD_MASK_ALL:
                LOG.warning('Cannot unmask all mcast forwarding on bridge %s; '
                            'some frames (LACP, LLDP) will be dropped by it',
                            self.name)
                self.set_group_fwd_mask(mask=BRIDGE_FWD_MASK)
            else:
                LOG.error('Cannot unmask any mcast forwarding on bridge %s',
                          self.name)

    def set_ageing(self, ageing, physical_ageing, physical):
        if ageing is None:
            return
        if physical and not physical_ageing:
            ageing = 0
        try:
            self._tee(BRIDGE_AGEING_FS, ageing)
        except RuntimeError:
            LOG.error('Cannot set ageing on bridge %s', self.name)

    def set_multicast_snooping(self, snooping):
        if snooping is None:
            return
        try:
            self._tee(BRIDGE_SNOOPING_FS, snooping)
        except RuntimeError:
            LOG.error('Cannot set snooping on bridge %s', self.name)
