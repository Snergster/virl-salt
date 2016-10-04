{% set l2_port2_enabled = salt['pillar.get']('virl:l2_port2_enabled', salt['grains.get']('l2_port2_enabled', 'True' )) %}
{% set l2_port = salt['pillar.get']('virl:l2_port', salt['grains.get']('l2_port', 'eth1' )) %}
{% set l2_network = salt['pillar.get']('virl:l2_network', salt['grains.get']('l2_network', '172.16.1.0/24' )) %}
{% set l2_network2 = salt['pillar.get']('virl:l2_network2', salt['grains.get']('l2_network2', '172.16.2.0/24' )) %}
{% set l2_gateway = salt['pillar.get']('virl:l2_network_gateway', salt['grains.get']('l2_network_gateway', '172.16.1.1' )) %}
{% set l2_gateway2 = salt['pillar.get']('virl:l2_network_gateway2', salt['grains.get']('l2_network_gateway2', '172.16.2.1' )) %}
{% set l2_start_address = salt['pillar.get']('virl:l2_start_address', salt['grains.get']('l2_start_address', '172.16.1.50' )) %}
{% set l2_end_address = salt['pillar.get']('virl:l2_end_address', salt['grains.get']('l2_end_address', '172.16.1.253' )) %}
{% set l2_start_address2 = salt['pillar.get']('virl:l2_start_address2', salt['grains.get']('l2_start_address2', '172.16.2.50' )) %}
{% set l2_end_address2 = salt['pillar.get']('virl:l2_end_address2', salt['grains.get']('l2_end_address2', '172.16.2.253' )) %}
{% set l2_address = salt['pillar.get']('virl:l2_address', salt['grains.get']('l2_address', '172.16.1.254' )) %}
{% set l2_address2 = salt['pillar.get']('virl:l2_address2', salt['grains.get']('l2_address2', '172.16.2.254' )) %}
{% set l3_port = salt['pillar.get']('virl:l3_port', salt['grains.get']('l3_port', 'eth3' )) %}
{% set l3_network = salt['pillar.get']('virl:l3_network', salt['grains.get']('l3_network', '172.16.3.0/24' )) %}
{% set l3_mask = salt['pillar.get']('virl:l3_mask', salt['grains.get']('l3_mask', '255.255.255.0' )) %}
{% set l3_gateway = salt['pillar.get']('virl:l3_network_gateway', salt['grains.get']('l3_network_gateway', '172.16.3.1' )) %}
{% set l3_start_address = salt['pillar.get']('virl:l3_floating_start_address', salt['grains.get']('l3_floating_start_address', '172.16.3.50' )) %}
{% set l3_end_address = salt['pillar.get']('virl:l3_floating_end_address', salt['grains.get']('l3_floating_end_address', '172.16.3.253' )) %}
{% set l3_address = salt['pillar.get']('virl:l3_address', salt['grains.get']('l3_address', '172.16.3.254/24' )) %}
{% set l2_port2 = salt['pillar.get']('virl:l2_port2', salt['grains.get']('l2_port2', 'eth2' )) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set controllerip = salt['pillar.get']('virl:internalnet_controller_ip',salt['grains.get']('internalnet_controller_ip', '172.16.10.250')) %}
{% set flat_dns = salt['pillar.get']('virl:first_flat_nameserver',salt['grains.get']('first_flat_nameserver', '8.8.8.8')) %}
{% set flat_dns2 = salt['pillar.get']('virl:second_flat_nameserver',salt['grains.get']('second_flat_nameserver', '8.8.4.4')) %}
{% set flat1_dns = salt['pillar.get']('virl:first_flat2_nameserver',salt['grains.get']('first_flat2_nameserver', '8.8.8.8')) %}
{% set flat1_dns2 = salt['pillar.get']('virl:second_flat2_nameserver',salt['grains.get']('second_flat2_nameserver', '8.8.4.4')) %}
{% set snat_dns = salt['pillar.get']('virl:first_snat_nameserver',salt['grains.get']('first_snat_nameserver', '8.8.8.8')) %}
{% set snat_dns2 = salt['pillar.get']('virl:second_snat_nameserver',salt['grains.get']('second_snat_nameserver', '8.8.4.4')) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', true)) %}
{% from "virl.jinja" import virl with context %}
include:
  - openstack.neutron.changes

neutron lives:
  service.running:
    - name: neutron-server
  cmd.run:
    - name: sleep 15

{% if virl.mitaka %}

project_domain_env:
  environ.setenv:
    - name: OS_PROJECT_DOMAIN_ID
    - value: default

user_domain_env:
  environ.setenv:
    - name: OS_USER_DOMAIN_ID
    - value: default

{% endif %}

create flat net:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} net-create flat --shared --provider:network_type flat --provider:physical_network flat
    - unless: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} net-show flat
    - require:
      - cmd: neutron lives

{% if l2_port2_enabled %}
create flat1 net:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} net-create flat1 --shared --provider:network_type flat --provider:physical_network flat1
    - unless: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} net-show flat1
    - require:
      - cmd: neutron lives

{% endif %}


create snat net:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} net-create ext-net --shared --provider:network_type flat --router:external --provider:physical_network ext-net
    - unless: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} net-show ext-net
    - require:
      - cmd: neutron lives

create snat net external:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} net-update --shared=true ext-net
    - require:
      - cmd: neutron lives
      - cmd: create snat net

create flat subnet:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} subnet-create flat {{ l2_network }} --allocation-pool start={{l2_start_address}},end={{l2_end_address}} --gateway {{ l2_gateway }} --name flat --dns-nameservers list=true {{ flat_dns }} {{ flat_dns2 }}
    - unless: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} subnet-show flat
    - require:
      - cmd: create flat net

create flat host port:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} port-create --fixed-ip ip_address={{ l2_address.split('/')[0] }} --name virl-host-flat flat
    - unless: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} port-show virl-host-flat
    - require:
      - cmd: create flat subnet

{% if l2_port2_enabled %}
create flat1 subnet:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} subnet-create flat1 {{ l2_network2 }} --allocation-pool start={{l2_start_address2}},end={{l2_end_address2}} --gateway {{ l2_gateway2 }} --name flat1 --dns-nameservers list=true {{ flat1_dns }} {{ flat1_dns2 }}
    - unless: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} subnet-show flat1
    - require:
      - cmd: create flat1 net

create flat1 host port:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} port-create --fixed-ip ip_address={{ l2_address2.split('/')[0] }} --name virl-host-flat1 flat1
    - unless: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} port-show virl-host-flat1
    - require:
      - cmd: create flat1 subnet

{% endif %}

create snat subnet:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} subnet-create ext-net {{ l3_network }} --allocation-pool start={{l3_start_address}},end={{l3_end_address}} --gateway {{ l3_gateway }} --name ext-net --dns-nameservers list=true {{ snat_dns }} {{ snat_dns2 }}
    - unless: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} subnet-show ext-net
    - require:
      - cmd: create snat net

create ext-net router-gateway:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ virl.keystone_auth_version }} router-list -c id -f csv | grep -o '[a-fA-F0-9-]\{36\}' | xargs -IX -n 1 neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ virl.keystone_auth_version }} router-gateway-set X ext-net
    - onlyif: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://{{ controllerip }}:5000/{{ virl.keystone_auth_version }} subnet-show ext-net

create ext-net host port:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} floatingip-create --floating-ip-address {{ l3_address.split('/')[0] }} ext-net
    - require:
      - cmd: create snat subnet

create quota update:
  cmd.run:
    - name: neutron --os-tenant-name admin --os-username admin --os-password {{ virl.ospassword }} --os-auth-url=http://127.0.1.1:5000/{{ virl.keystone_auth_version }} quota-update --router -1
