{% set ospassword = salt['grains.get']('password', 'password') %}
{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set ks_token = salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh') %}
{% set uwmpassword = salt['grains.get']('uwmadmin_password', 'password') %}
{% set admin_tenid = salt.keystone.tenant_get(name='admin') %}

include:
  - openstack.keystone.install
  - openstack.keystone.setup

glance endpoint:
  keystone.endpoint_present:
    - name: glance
    - publicurl: http://{{ public_ip }}:9292
    - internalurl: http://{{ public_ip }}:9292
    - adminurl: http://{{ public_ip }}:9292
    - require:
      - cmd: key-db-sync

keystone endpoint:
  keystone.endpoint_present:
    - name: keystone
    - publicurl: http://{{ public_ip }}:5000/v2.0
    - internalurl: http://{{ public_ip }}:5000/v2.0
    - adminurl: http://{{ public_ip }}:35357/v2.0
    - require:
      - cmd: key-db-sync

neutron endpoint:
  keystone.endpoint_present:
    - name: neutron
    - publicurl: http://{{ public_ip }}:9696
    - internalurl: http://{{ public_ip }}:9696
    - adminurl: http://{{ public_ip }}:9696
    - require:
      - cmd: key-db-sync

nova endpoint:
  keystone.endpoint_present:
    - name: nova
    - publicurl: http://{{ public_ip }}:8774/v2/$(tenant_id)s
    - internalurl: http://{{ public_ip }}:8774/v2/$(tenant_id)s
    - adminurl: http://{{ public_ip }}:8774/v2/$(tenant_id)s
    - require:
      - cmd: key-db-sync

cinder endpoint:
  keystone.endpoint_present:
    - name: cinder
    - publicurl: http://{{ public_ip }}:8776/v1/$(tenant_id)s
    - internalurl: http://{{ public_ip }}:8776/v1/$(tenant_id)s
    - adminurl: http://{{ public_ip }}:8776/v1/$(tenant_id)s
    - require:
      - cmd: key-db-sync

cinderv2 endpoint:
  keystone.endpoint_present:
    - name: cinderv2
    - publicurl: http://{{ public_ip }}:8776/v2/$(tenant_id)s
    - internalurl: http://{{ public_ip }}:8776/v2/$(tenant_id)s
    - adminurl: http://{{ public_ip }}:8776/v2/$(tenant_id)s
    - require:
      - cmd: key-db-sync

orchestration endpoint:
  keystone.endpoint_present:
    - name: heat
    - publicurl: http://{{ public_ip }}:8004/v1/$(tenant_id)s
    - internalurl: http://{{ public_ip }}:8004/v1/$(tenant_id)s
    - adminurl: http://{{ public_ip }}:8004/v1/$(tenant_id)s
    - require:
      - cmd: key-db-sync

cloudformation endpoint:
  keystone.endpoint_present:
    - name: heat-cfn
    - publicurl: http://{{ public_ip }}:8000/v1
    - internalurl: http://{{ public_ip }}:8000/v1
    - adminurl: http://{{ public_ip }}:8000/v1
    - require:
      - cmd: key-db-sync

nova_admin_tenant_id insert:
  cmd.run:
    - name: crudini --set /etc/salt/minion.d/openstack.conf env keystone.tenant_id {{ admin_tenid.admin.id }}
    - require:
      - keystone: Keystone tenants
      
