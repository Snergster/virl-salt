{% set neutronpassword = salt['grains.get']('password', 'password') %}
{% set ospassword = salt['grains.get']('password', 'password') %}
{% set rabbitpassword = salt['grains.get']('password', 'password') %}
{% set metapassword = salt['grains.get']('password', 'password') %}
{% set hostname = salt['grains.get']('hostname', 'virl') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set keystone_service_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set neutid = salt['grains.get']('neutron_extnet_id', ' ') %}
{% set int_ip = salt['grains.get']('internalnet_ip', '172.16.10.250' ) %}
{% set service_tenid = salt['keystone.tenant_get'](name='service') %}

l3-gateway set:
  openstack_config.present:
    - filename: /etc/neutron/l3_agent.ini
    - section: 'DEFAULT'
    - parameter: 'gateway_external_network_id'
    - value: ' '

nova_admin_tenant_id insert in changes:
  openstack_config.present:
    - filename: /etc/neutron/neutron.conf
    - section: 'DEFAULT'
    - parameter: 'nova_admin_tenant_id'
    - value: {{ service_tenid.service.id }}

service_tenant_id in grains:
    grains.present:
        - name: service_id
        - value: {{ service_tenid.service.id }}
