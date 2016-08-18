# Copyright 2012 Cisco Systems, Inc.  All rights reserved.
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

from oslo_config import cfg

from neutron._i18n import _

DEFAULT_BRIDGE_MAPPINGS = []
DEFAULT_INTERFACE_MAPPINGS = []
DEFAULT_VXLAN_GROUP = '224.0.0.1'
DEFAULT_KERNEL_HZ_VALUE = 250  # [Hz]
DEFAULT_TC_TBF_LATENCY = 50  # [ms]

vxlan_opts = [
    cfg.BoolOpt('enable_vxlan', default=True,
                help=_("Enable VXLAN on the agent. Can be enabled when "
                       "agent is managed by ml2 plugin using linuxbridge "
                       "mechanism driver")),
    cfg.IntOpt('ttl',
               help=_("TTL for vxlan interface protocol packets.")),
    cfg.IntOpt('tos',
               help=_("TOS for vxlan interface protocol packets.")),
    cfg.StrOpt('vxlan_group', default=DEFAULT_VXLAN_GROUP,
               help=_("Multicast group(s) for vxlan interface. A range of "
                      "group addresses may be specified by using CIDR "
                      "notation. Specifying a range allows different VNIs to "
                      "use different group addresses, reducing or eliminating "
                      "spurious broadcast traffic to the tunnel endpoints. "
                      "To reserve a unique group for each possible "
                      "(24-bit) VNI, use a /8 such as 239.0.0.0/8. This "
                      "setting must be the same on all the agents.")),
    cfg.IPOpt('local_ip', help=_("Local IP address of the VXLAN endpoints.")),
    cfg.BoolOpt('l2_population', default=False,
                help=_("Extension to use alongside ml2 plugin's l2population "
                       "mechanism driver. It enables the plugin to populate "
                       "VXLAN forwarding table.")),
    cfg.BoolOpt('arp_responder', default=False,
                help=_("Enable local ARP responder which provides local "
                       "responses instead of performing ARP broadcast into "
                       "the overlay. Enabling local ARP responder is not fully"
                       "compatible with the allowed-address-pairs extension.")
                ),
]

bridge_opts = [
    cfg.ListOpt('physical_interface_mappings',
                default=DEFAULT_INTERFACE_MAPPINGS,
                help=_("Comma-separated list of "
                       "<physical_network>:<physical_interface> tuples "
                       "mapping physical network names to the agent's "
                       "node-specific physical network interfaces to be used "
                       "for flat and VLAN networks. All physical networks "
                       "listed in network_vlan_ranges on the server should "
                       "have mappings to appropriate interfaces on each "
                       "agent.")),
    cfg.ListOpt('bridge_mappings',
                default=DEFAULT_BRIDGE_MAPPINGS,
                help=_("List of <physical_network>:<physical_bridge>")),
]

qos_options = [
    cfg.IntOpt('kernel_hz', default=DEFAULT_KERNEL_HZ_VALUE,
               help=_("Value of host kernel tick rate (hz) for calculating "
                      "minimum burst value in bandwidth limit rules for "
                      "a port with QoS. See kernel configuration file for "
                      "HZ value and tc-tbf manual for more information.")),
    cfg.IntOpt('tbf_latency', default=DEFAULT_TC_TBF_LATENCY,
               help=_("Value of latency (ms) for calculating size of queue "
                      "for a port with QoS. See tc-tbf manual for more "
                      "information."))
]

extra_opts = [
    cfg.IntOpt('network_device_mtu',
               help=_("MTU used for VIFs")),
    cfg.IntOpt('network_bridge_ageing', default=None,
               help=_("Bridge MAC learning timeout (0 = disable)")),
    cfg.BoolOpt('network_physical_ageing', default=False,
               help=_("Bridge MAC learning controls physical networks too")),
    cfg.IntOpt('network_bridge_multicast_snooping', default=None,
               help=_("Bridge multicast snooping (0 = disable)")),
]

cfg.CONF.register_opts(vxlan_opts, "VXLAN")
cfg.CONF.register_opts(bridge_opts, "LINUX_BRIDGE")
cfg.CONF.register_opts(extra_opts)
cfg.CONF.register_opts(qos_options, "QOS")
