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

"""
Websocket proxy that is compatible with OpenStack Nova
Serial consoles. Leverages websockify.py by Joel Martin.
Based on nova-novncproxy.
"""
import sys
import os

from oslo_config import cfg

from nova.cmd import baseproxy
from nova import config
from nova import utils


opts = [
    cfg.StrOpt('proxyclient_address',
               default='0.0.0.0',
               help='Host on which to connect to with requests'),
    cfg.StrOpt('serialproxy_host',
               default='0.0.0.0',
               help='Host on which to listen for incoming requests'),
    cfg.IntOpt('serialproxy_port',
               default=6083,
               help='Port on which to listen for incoming requests'),
    ]

CONF = cfg.CONF
CONF.register_cli_opts(opts, group="serial_console")


def main():
    # set default web flag option
    web = '/usr/share/nova-serial'
    #web = os.path.join(os.path.dirname(__file__), 'serialproxy_web')
    CONF.set_default('web', web)
    config.parse_args(sys.argv)

    proxyclient_address = CONF.serial_console.proxyclient_address
    if proxyclient_address == '0.0.0.0':
        # determine the correct host to connect to as the local address
        # of the interface with the best default route
        import subprocess, re
        command = "route -n | awk '/^0.0.0.0/{print $5 \" \" $8}'"
        prc = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
        out, _ = prc.communicate()
        routes = [line.split(None, 1) for line in out.splitlines()]
        if routes:
            routes.sort(key=lambda metr_iface: int(metr_iface[0]))
            selected_iface = routes[0][1]

            command = "ifconfig %s" % selected_iface
            prc = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
            out, _ = prc.communicate()
            outside_ip = re.search(r'inet (?:addr:)?([^\s]+)', out)
            if outside_ip:
                proxyclient_address = outside_ip.group(1)


    baseproxy.proxy(
        target_host=proxyclient_address,
        host=CONF.serial_console.serialproxy_host,
        port=CONF.serial_console.serialproxy_port)
