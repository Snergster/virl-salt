

{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl') %}
{% set domain = salt['pillar.get']('virl:domain', salt['grains.get']('domain', 'cisco.com') %}
{% set dhcp = salt['pillar.get']('virl:using_dhcp_on_the_public_port', salt['grains.get']('using_dhcp_on_the_public_port', True ) %}
{% set publicport = salt['pillar.get']('virl:public_port', salt['grains.get']('public_port', 'eth0') %}
{% set public_ip = salt['pillar.get']('virl:static_ip', salt['grains.get']('static_ip', '127.0.0.1' ) %}

{% set public_network = salt['pillar.get']('virl:public_network', salt['grains.get']('public_network', '172.16.6.0' ) %}
{% set public_netmask = salt['pillar.get']('virl:public_netmask', salt['grains.get']('public_netmask', '255.255.255.0' ) %}
{% set public_gateway = salt['pillar.get']('virl:public_gateway', salt['grains.get']('public_gateway', '172.16.6.1' ) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', False) %}
{% set ntp_server = salt['pillar.get']('virl:ntp_server', salt['grains.get']('ntp_server', False) %}
{% set fdns = salt['pillar.get']('virl:first_nameserver', salt['grains.get']('first_nameserver', '8.8.8.8' ) %}
{% set sdns = salt['pillar.get']('virl:second_nameserver', salt['grains.get']('second_nameserver', '8.8.4.4' ) %}
{% set l2_port = salt['pillar.get']('virl:l2_port', salt['grains.get']('l2_port', 'eth1' ) %}
{% set l2_network = salt['pillar.get']('virl:l2_network', salt['grains.get']('l2_network', '172.16.1.0/24' ) %}
{% set l2_mask = salt['pillar.get']('virl:l2_mask', salt['grains.get']('l2_mask', '255.255.255.0' ) %}
{% set l2_gateway = salt['pillar.get']('virl:l2_network_gateway', salt['grains.get']('l2_network_gateway', '172.16.1.1' ) %}
{% set l2_start_address = salt['pillar.get']('virl:l2_start_address', salt['grains.get']('l2_start_address', '172.16.1.50' ) %}
{% set l2_end_address = salt['pillar.get']('virl:l2_end_address', salt['grains.get']('l2_end_address', '172.16.1.253' ) %}

{% set l2_address = salt['pillar.get']('virl:l2_address', salt['grains.get']('l2_address', '172.16.1.254' ) %}
{% set ffdns = salt['pillar.get']('virl:first_flat_nameserver', salt['grains.get']('first_flat_nameserver', '8.8.8.8' ) %}
{% set sfdns = salt['pillar.get']('virl:second_flat_nameserver', salt['grains.get']('second_flat_nameserver', '8.8.4.4' ) %}

{% set l2_port2_enabled = salt['pillar.get']('virl:l2_port2_enabled', salt['grains.get']('l2_port2_enabled', 'True' ) %}
{% set l2_port2 = salt['pillar.get']('virl:l2_port2', salt['grains.get']('l2_port2', 'eth2' ) %}
{% set l2_network2 = salt['pillar.get']('virl:l2_network2', salt['grains.get']('l2_network2', '172.16.2.0/24' ) %}
{% set l2_mask2 = salt['pillar.get']('virl:l2_mask2', salt['grains.get']('l2_mask2', '255.255.255.0' ) %}
{% set l2_gateway2 = salt['pillar.get']('virl:l2_network_gateway2', salt['grains.get']('l2_network_gateway2', '172.16.2.1' ) %}
{% set l2_start_address2 = salt['pillar.get']('virl:l2_start_address2', salt['grains.get']('l2_start_address2', '172.16.2.50' ) %}
{% set l2_end_address2 = salt['pillar.get']('virl:l2_end_address2', salt['grains.get']('l2_end_address2', '172.16.2.253' ) %}
{% set ff2dns = salt['pillar.get']('virl:first_flat2_nameserver', salt['grains.get']('first_flat2_nameserver', '8.8.8.8' ) %}
{% set sf2dns = salt['pillar.get']('virl:second_flat2_nameserver', salt['grains.get']('second_flat2_nameserver', '8.8.4.4' ) %}
{% set l2_address2 = salt['pillar.get']('virl:l2_address2', salt['grains.get']('l2_address2', '172.16.2.254' ) %}

{% set l3_port = salt['pillar.get']('virl:l3_port', salt['grains.get']('l3_port', 'eth3' ) %}
{% set l3_network = salt['pillar.get']('virl:l3_mask', salt['grains.get']('l3_mask', '172.16.3.0/24' ) %}
{% set l3_mask = salt['pillar.get']('virl:l3_mask', salt['grains.get']('l3_mask', '255.255.255.0' ) %}
{% set l3_network_gateway = salt['pillar.get']('virl:l3_network_gateway', salt['grains.get']('l3_network_gateway', '172.16.3.1' ) %}
{% set l3_floating_start_address = salt['pillar.get']('virl:l3_floating_start_address', salt['grains.get']('l3_floating_start_address', '172.16.3.50' ) %}
{% set l3_floating_end_address = salt['pillar.get']('virl:l3_floating_end_address', salt['grains.get']('l3_floating_end_address', '172.16.3.253' ) %}
{% set l3_address = salt['pillar.get']('virl:l3_address', salt['grains.get']('l3_address', '172.16.3.254/24' ) %}

{% set ramdisk = salt['pillar.get']('virl:ramdisk', salt['grains.get']('ramdisk', False) %}
{% set ank = salt['pillar.get']('virl:ank', salt['grains.get']('ank', '19401') %}
{% set uwmport = salt['pillar.get']('virl:virl_webservices', salt['grains.get']('virl_webservices', '193991') %}
{% set stdport = salt['pillar.get']('virl:virl_user_management', salt['grains.get']('virl_user_management', '19400') %}
{% set serstart = salt['pillar.get']('virl:start_of_serial_port_range', salt['grains.get']('start_of_serial_port_range', '17000') %}
{% set serend = salt['pillar.get']('virl:end_of_serial_port_range', salt['grains.get']('end_of_serial_port_range', '18000') %}
{% set vnc = salt['pillar.get']('virl:vnc', salt['grains.get']('vnc', False) %}
{% set vnc_password = salt['pillar.get']('virl:vnc_password', salt['grains.get']('vnc_password', 'letmein') %}
{% set guestaccount = salt['pillar.get']('virl:guest_account', salt['grains.get']('guest_account', True) %}
{% set user_list = salt['pillar.get']('virl:user_list', salt['grains.get']('user_list', '') %}
{% set desktop = salt['pillar.get']('virl:desktop', salt['grains.get']('desktop', False) %}
{% set uwmpassword = salt['pillar.get']('virl:uwmadmin_password', salt['grains.get']('uwmadmin_password', 'password')) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password') %}
{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password') %}
{% set ks_token = salt['pillar.get']('virl:keystone_service_token', salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh')) %}
{% set ganglia = salt['pillar.get']('virl:ganglia', salt['grains.get']('ganglia', False) %}
{% set debug = salt['pillar.get']('virl:debug', salt['grains.get']('debug', False) %}
{% set ceilometer = salt['pillar.get']('virl:ceilometer', salt['grains.get']('ceilometer', False) %}
{% set enable_horizon = salt['pillar.get']('virl:enable_horizon', salt['grains.get']('enable_horizon', True) %}
{% set enable_heat = salt['pillar.get']('virl:enable_heat', salt['grains.get']('enable_heat', True) %}
{% set enable_cinder = salt['pillar.get']('virl:enable_cinder', salt['grains.get']('enable_cinder', True) %}
{% set cinder_file = salt['pillar.get']('virl:cinder_file', salt['grains.get']('cinder_file', False) %}
{% set cinder_size = salt['pillar.get']('virl:cinder_size', salt['grains.get']('cinder_size', '2000') %}
{% set cinder_location = salt['pillar.get']('virl:cinder_location', salt['grains.get']('cinder_location', '/var/lib/cinder/cinder-volumes.lvm') %}
{% set dummy_int = salt['pillar.get']('virl:dummy_int', salt['grains.get']('dummy_int', False ) %}
{% set jumbo_frames = salt['pillar.get']('virl:jumbo_frames', salt['grains.get']('jumbo_frames', False ) %}
{% set iscontroller = salt['pillar.get']('virl:this_node_is_the_controller', salt['grains.get']('this_node_is_the_controller', True ) %}

{% set controllerhname = salt['pillar.get']('virl:internalnet_controller_hostname', salt['grains.get']('internalnet_controller_hostname', 'controller') %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP', salt['grains.get']('internalnet_controller_IP', '172.16.10.250') %}
{% set int_port = salt['pillar.get']('virl:internalnet_port', salt['grains.get']('internalnet_port', 'eth4' ) %}
{% set int_ip = salt['pillar.get']('virl:internalnet_ip', salt['grains.get']('internalnet_ip', '172.16.10.250' ) %}
{% set int_network = salt['pillar.get']('virl:internalnet_network', salt['grains.get']('internalnet_network', '172.16.10.0' ) %}
{% set int_mask = salt['pillar.get']('virl:internalnet_netmask', salt['grains.get']('internalnet_netmask', '255.255.255.0' ) %}
{% set int_gateway = salt['pillar.get']('virl:internalnet_gateway', salt['grains.get']('internalnet_gateway', '172.16.10.1' ) %}
{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set novapassword = salt['pillar.get']('virl:novapassword', salt['grains.get']('password', 'password') %}
{% set neutronpassword = salt['pillar.get']('virl:neutronpassword', salt['grains.get']('password', 'password') %}
{% set glancepassword = salt['pillar.get']('virl:glancepassword', salt['grains.get']('password', 'password') %}
{% set heatpassword = salt['pillar.get']('virl:heatpassword', salt['grains.get']('password', 'password') %}









to be retired

{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP', salt['grains.get']('internalnet_controller_IP', '172.16.10.250') %}
{% set uwmpass = salt['pillar.get']('virl:x', salt['grains.get']('uwmadmin_password', 'password') %}
{% set ifhorizon = salt['pillar.get']('virl:enable_horizon', salt['grains.get']('enable_horizon', 'False') %}
