#! /usr/bin/env python

# CLI menu for VIRL setup
# Copyright (c) 2017, Cisco Systems, Inc.
# All rights reserved.

from __future__ import print_function

import sys
import subprocess
import signal
import os
import datetime
import configparser

VINSTALL_CFG = '/etc/virl.ini'

class Config():
    """ Handler for configuration files """

    def __init__(self, path, default_section=None):
        self._default_section = default_section if default_section else 'DEFAULT'
        self._path = path
        self._safeparser = configparser.ConfigParser()
        self._safeparser.optionxform = str  # Preserve keys' case
        self._safeparser.read(path)

    @property
    def path(self):
        return self._path

    @property
    def default_section(self):
        return self._default_section

    @property
    def parser(self):
        return self._safeparser

    def get_section(self, section=None):
        section = section if section else self.default_section
        return dict(self.parser.items(section))

    def get(self, field, section=None, default=None):
        section = section if section else self.default_section
        try:
            return self.parser.get(section, field)
        except configparser.NoOptionError:
            return default

    def get_all(self):
        result = dict()
        for name, section in self.parser.iteritems():
            result[name] = dict()
            for field, value in section.iteritems():
                result[name][field] = value
        return result

    def set(self, field, value, section=None):
        section = section if section else self.default_section
        if section != self.default_section and not self.parser.has_section(section):
            self.parser.add_section(section)
        self.parser.set(section, field, value)

    def delete(self, field, section=None):
        section = section if section else self.default_section
        self.parser.remove_option(section, field)

    def write(self, path=None):
        path = path if path else self.path
        with open(path, 'wb') as configfile:
            self.parser.write(configfile)


OPENSTACK_SERVICES = [
    'nova-api.service',
    'nova-compute.service',
    'nova-consoleauth.service',
    'nova-cert.service',
    'nova-conductor.service',
    'nova-novncproxy.service',
    'nova-serialproxy.service',
    'neutron-dhcp-agent.service',
    'neutron-linuxbridge-cleanup.service ',
    'neutron-server.service',
    'neutron-l3-agent.service',
    'neutron-metadata-agent.service',
    'neutron-linuxbridge-agent.service',
    'glance-api.service',
    'glance-registry.service',
    'keystone.service',
    'mysql.service ',
    'rabbitmq-server.service'
]

VIRL_SERVICES = [
    'virl-std.service',
    'virl-tap-counter.service',
    'redis.service',
    'redis-server.service',
    'virl-uwm.service',
    'virl-webmux.service',
    'ank-cisco-webserver.service',
    'virl-vis-mux.service',
    'virl-vis-processor.service',
    'virl-vis-webserver.service'
]

LOG_PATHS = [
    '/var/local/virl/logs/std_server.log',
    '/var/local/virl/logs/uwm_server.log',
    '/var/log/virl_tap_counter.log'
]


def is_sudo():
    return os.getuid() == 0


def run_command(command, on_success_msg='', require_sudo=False):
    try:
        subprocess.check_call(command, shell=True)
    except subprocess.CalledProcessError as exc:
        print('failed with stderr: {}'.format(exc.output))
    else:
        if on_success_msg:
            print(on_success_msg)


def run_salt_state(state):
    print('Restarting OpenStack workers')
    cmd = 'salt-call state.sls {} --state_verbose=False --state-output=terse'.format(state)
    success_msg = ''
    run_command(cmd, success_msg, require_sudo=True)


def press_return_to_continue(next_state=''):
    print('')
    print('press return to continue')
    raw_input()
    fsm(next_state)


def read_next_state(previous_state, default='0'):
    print('Select state (default {}): '.format(default), end='')

    inp = raw_input() or default

    if len(previous_state) >= 1:
        next_state = '{}.{}'.format(previous_state, inp)
    else:
        next_state = '{}'.format(inp)

    if next_state in STATES:
        fsm(next_state)
    else:
        fsm(previous_state, True)


def restart_docker():
    print('restarting docker registry')
    cmd = 'docker restart registry'
    success_msg = 'docker registry restarted'
    run_command(cmd, success_msg, require_sudo=True)


def restart_service(name):
    print('')
    print('restarting {}'.format(name))
    cmd = 'systemctl restart {}'.format(name)
    success_msg = '{} restarted'.format(name)
    run_command(cmd, success_msg, require_sudo=True)


def show_status(name):
    print('')
    print('Status of service {}'.format(name))
    cmd = "systemctl --lines=0 --output=short status {} | grep 'Active:\|Memory:\|CPU:'".format(name)
    run_command(cmd)


#    #   ##   #    # #####  #      ###### #####   ####
#    #  #  #  ##   # #    # #      #      #    # #
###### #    # # #  # #    # #      #####  #    #  ####
#    # ###### #  # # #    # #      #      #####       #
#    # #    # #   ## #    # #      #      #   #  #    #
#    # #    # #    # #####  ###### ###### #    #  ####


def handle_start():
    current_state = ''
    print('****** Main menu ******')
    print('')
    print('1. Network configuration')
    print('2. Maintenance')
    print('3. Diagnostic')
    print('')
    print('0. Exit')
    read_next_state(current_state)


def handle_0():
    sys.exit()


def handle_1():
    current_state = '1'
    print('***** Network configuration *****')
    print('')
    print('1. Switch primary interface')
    print('2. Run DHCP on primary interface')
    print('3. Static IP configuration on primary interface')
    print('4. DNS configuration')
    print('5. NTP server')
    print('')
    print('0. Back')
    read_next_state(current_state)

def handle_1_1():
    config = Config(path=VINSTALL_CFG)
    current = config.get(field='public_port')
    interface = raw_input("Interface (%s): " % current) or current
    config.set(field='public_port', value=interface)
    config.write()

    press_return_to_continue('1.0')


def handle_1_2():
    config = Config(VINSTALL_CFG)
    config.set(field='using_dhcp_on_the_public_port', value='True')
    config.write()

    # TODO: run dhcp

    press_return_to_continue('1.0')


def handle_1_3():
    config = Config(VINSTALL_CFG)
    config.set(field='using_dhcp_on_the_public_port', value='False')
    # static ip
    default = config.get(field='Static_IP') or '172.16.6.250'
    ip = raw_input("Static IP (default: %s): " % default) or default
    config.set(field='Static_IP', value=ip)
    # public network
    default = config.get(field='public_network') or '172.16.6.0'
    net = raw_input("Public network (default: %s): " % default) or default
    config.set(field='public_network', value=net)
    # public_netmask
    default = config.get(field='public_netmask') or '255.255.255.0'
    mask = raw_input("Public netmask (default: %s): " % default) or default
    config.set(field='public_netmask', value=mask)
    # public_gateway:
    default = config.get(field='public_gateway') or '172.16.6.1'
    gateway = raw_input("Public gateway (default: %s): " % default) or default
    config.set(field='public_gateway', value=gateway)
    config.write()

    # TODO: configure interface
    press_return_to_continue('1.0')


def handle_1_4():
    press_return_to_continue('1.0')


def handle_1_5():
    press_return_to_continue('1.0')


def handle_2():
    current_state = '2'
    print('***** Maintenance ******')
    print('')
    print('1. Restart VIRL services')
    print('2. Restart OpenStack services')
    print('3. Restart OpenStack worker pools')
    print('')
    print('0. Back')
    read_next_state(current_state)


def handle_2_1():
    current_state = '2.1'
    print('***** Maintenance - VIRL services restart *****')
    print('')
    print('1. All VIRL services')
    print('2. STD services (includes redis)')
    print('3. UWM services (includes webmux)')
    print('4. ANK services')
    print('5. Live visualisation services')
    print('6. Docker registry')
    print('')
    print('0. Back')
    read_next_state(current_state)


def handle_2_1_1():
    print('***** Restarting all VIRL services *****')
    for service in VIRL_SERVICES:
        restart_service(service)
    restart_docker()
    press_return_to_continue('2.1')


def handle_2_1_2():
    print('***** Restarting STD services *****')
    restart_service('virl-std.service')
    restart_service('virl-tap-counter.service')
    restart_service('redis.service')
    restart_service('redis-server.service')
    press_return_to_continue('2.1')


def handle_2_1_3():
    print('***** Restarting UWM services ******')
    restart_service('virl-uwm.service')
    restart_service('virl-webmux.service')
    press_return_to_continue('2.1')


def handle_2_1_4():
    print('***** Restarting ANK services *****')
    restart_service('ank-cisco-webserver.service')
    press_return_to_continue('2.1')


def handle_2_1_5():
    print('***** Restarting live visualisation services *****')
    restart_service('virl-vis-mux.service')
    restart_service('virl-vis-processor.service')
    restart_service('virl-vis-webserver.service')
    press_return_to_continue('2.1')


def handle_2_1_6():
    print('***** Restarting docker registry *****')
    print('')
    restart_docker()
    press_return_to_continue('2.1')


def handle_2_2():
    current_state = '2.2'
    print('***** Maintenance - OpenStack services restart *****')
    print('')
    print('1. All OpenStack and infrastructure services')
    print('2. All Compute Services')
    print('3. All Networking Services')
    print('4. All Image Services')
    print('5. Identity service')
    print('6. Infrastructure services (MySql, RabbitMQ)')
    print('')
    print('0. Back')
    read_next_state(current_state)


def handle_2_2_1():
    print('***** Restarting OpenStack services *****')
    for service in OPENSTACK_SERVICES:
        restart_service(service)
    press_return_to_continue('2.2')


def handle_2_2_2():
    print('***** Restarting OpenStack Compute services *****')
    restart_service('nova-api.service')
    restart_service('nova-compute.service')
    restart_service('nova-consoleauth.service')
    restart_service('nova-cert.service')
    restart_service('nova-conductor.service')
    restart_service('nova-novncproxy.service')
    restart_service('nova-serialproxy.service')
    press_return_to_continue('2.2')


def handle_2_2_3():
    print('***** Restarting OpenStack Networking services *****')
    restart_service('neutron-dhcp-agent.service')
    restart_service('neutron-linuxbridge-cleanup.service ')
    restart_service('neutron-server.service')
    restart_service('neutron-l3-agent.service')
    restart_service('neutron-metadata-agent.service')
    restart_service('neutron-linuxbridge-agent.service')
    restart_service('neutron-ovs-cleanup.service')
    press_return_to_continue('2.2')


def handle_2_2_4():
    print('***** Restarting OpenStack Image services *****')
    restart_service('glance-api.service')
    restart_service('glance-registry.service')
    press_return_to_continue('2.2')


def handle_2_2_5():
    print('***** Restarting OpenStack Identity services *****')
    restart_service('keystone.service')
    press_return_to_continue('2.2')


def handle_2_2_6():
    print('***** Restarting OpenStack Infrastructure services *****')
    restart_service('mysql.service ')
    restart_service('rabbitmq-server.service')
    press_return_to_continue('2.2')


def handle_2_3():
    print('***** Restarting OpenStack worker pools *****')
    print('')
    print('This may take some time')
    print('')
    run_salt_state('openstack.worker_pool')
    press_return_to_continue('2')


def handle_3():
    current_state = '3'
    print('****** Diagnostics *****')
    print('')
    print('1. VIRL services status')
    print('2. Openstack services status')
    print('3. Health check')
    print('4. Collect logs')
    print('')
    print('0. Back')
    read_next_state(current_state)


def handle_3_1():
    print('***** VIRL services status *****')
    for service in VIRL_SERVICES:
        show_status(service)
    press_return_to_continue('3')


def handle_3_2():
    print('***** OpenStack services status *****')
    for service in OPENSTACK_SERVICES:
        show_status(service)
    press_return_to_continue('3')


def handle_3_3():
    print('***** Health check *****')
    print('')
    run_command('virl_health_status')
    press_return_to_continue('3')


def handle_3_4():
    print('***** Collecting logs *****')
    print('')
    print('collecting logs')
    files = ''
    for log_file in LOG_PATHS:
        if os.path.isfile(log_file):
            files += ' '
            files += log_file
    output_file = 'virl_logs_' + datetime.datetime.now().isoformat()
    output_path = '/var/log/virl_logs/'
    run_command('tar -zcvf {}{}.tgz {} 1>/dev/null 2>/dev/null'.format(output_path, output_file, files))
    print('logs are in {}{}.tgz'.format(output_path, output_file))
    press_return_to_continue('3')


def fsm(state, unknown_state=False):
    global STATES
    subprocess.call('clear')
    if unknown_state:
        print('Unknown command !')
        print('')
    else:
        print('')
        print('')
    STATES[state]()


def sigint_handler(signal, frame):
    print('Ctrl+C detected, exit.')
    sys.exit()


def main():
    if not is_sudo():
        print('You must run this script as root. \'sudo virl_setup\'')
        handle_0()

    signal.signal(signal.SIGINT, sigint_handler)
    fsm('')


STATES = {
    '': handle_start,
    '0': handle_0,
    '1': handle_1,
    '2': handle_2,
    '3': handle_3,
    '1.0': handle_start,
    '1.1': handle_1_1,
    '1.2': handle_1_2,
    '1.3': handle_1_3,
    '1.4': handle_1_4,
    '1.5': handle_1_5,
    '2.0': handle_start,
    '2.1': handle_2_1,
    '2.2': handle_2_2,
    '2.3': handle_2_3,
    '3.0': handle_start,
    '3.1': handle_3_1,
    '3.2': handle_3_2,
    '3.3': handle_3_3,
    '3.4': handle_3_4,
    '2.1.0': handle_2,
    '2.1.1': handle_2_1_1,
    '2.1.2': handle_2_1_2,
    '2.1.3': handle_2_1_3,
    '2.1.4': handle_2_1_4,
    '2.1.5': handle_2_1_5,
    '2.1.6': handle_2_1_6,
    '2.2.0': handle_2,
    '2.2.1': handle_2_2_1,
    '2.2.2': handle_2_2_2,
    '2.2.3': handle_2_2_3,
    '2.2.4': handle_2_2_4,
    '2.2.5': handle_2_2_5,
    '2.2.6': handle_2_2_6
}


if __name__ == '__main__':
    main()
