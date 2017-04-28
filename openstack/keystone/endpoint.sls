{% from "virl.jinja" import virl with context %}

include:
  - openstack.keystone.install
  - openstack.keystone.setup

glance endpoint:
  keystone.endpoint_present:
    - name: glance
    - publicurl: http://{{ virl.openstack_public_ip }}:9292
    - internalurl: http://{{ virl.controller_ip }}:9292
    - adminurl: http://{{ virl.controller_ip }}:9292
    - require:
      - cmd: key-db-sync

keystone endpoint:
  keystone.endpoint_present:
    - name: keystone
    - publicurl: http://{{ virl.openstack_public_ip }}:5000/{{ virl.keystone_auth_version }}
    - internalurl: http://{{ virl.controller_ip }}:5000/{{ virl.keystone_auth_version }}
    - adminurl: http://{{ virl.controller_ip }}:35357/{{ virl.keystone_auth_version }}
    - require:
      - cmd: key-db-sync

neutron endpoint delete:
  keystone.endpoint_absent:
    - name: neutron

neutron endpoint:
  keystone.endpoint_present:
    - name: neutron
    - publicurl: http://{{ virl.controller_ip }}:9696
    - internalurl: http://{{ virl.controller_ip }}:9696
    - adminurl: http://{{ virl.controller_ip }}:9696
    - require:
      - cmd: key-db-sync

nova endpoint:
  keystone.endpoint_present:
    - name: nova
    - publicurl: http://{{ virl.openstack_public_ip }}:8774/v2/$(tenant_id)s
    - internalurl: http://{{ virl.controller_ip }}:8774/v2/$(tenant_id)s
    - adminurl: http://{{ virl.controller_ip }}:8774/v2/$(tenant_id)s
    - require:
      - cmd: key-db-sync

{% if virl.mitaka %}
cinder endpoint:
  keystone.endpoint_present:
    - name: cinder
    - publicurl: http://{{ virl.openstack_public_ip }}:8776/v2/$(tenant_id)s
    - internalurl: http://{{ virl.controller_ip }}:8776/v2/$(tenant_id)s
    - adminurl: http://{{ virl.controller_ip }}:8776/v2/$(tenant_id)s
    - require:
      - cmd: key-db-sync
{% endif %}

{% if virl.kilo %}
cinder endpoint:
  keystone.endpoint_present:
    - name: cinder
    - publicurl: http://{{ virl.openstack_public_ip }}:8776/v1/$(tenant_id)s
    - internalurl: http://{{ virl.controller_ip }}:8776/v1/$(tenant_id)s
    - adminurl: http://{{ virl.controller_ip }}:8776/v1/$(tenant_id)s
    - require:
      - cmd: key-db-sync


cinder endpointv2:
  keystone.endpoint_present:
    - name: cinderv2
    - publicurl: http://{{ virl.openstack_public_ip }}:8776/v2/$(tenant_id)s
    - internalurl: http://{{ virl.controller_ip }}:8776/v2/$(tenant_id)s
    - adminurl: http://{{ virl.controller_ip }}:8776/v2/$(tenant_id)s
    - require:
      - cmd: key-db-sync
{% endif %}

orchestration endpoint:
  keystone.endpoint_present:
    - name: heat
    - publicurl: http://{{ virl.openstack_public_ip }}:8004/v1/$(tenant_id)s
    - internalurl: http://{{ virl.controller_ip }}:8004/v1/$(tenant_id)s
    - adminurl: http://{{ virl.controller_ip }}:8004/v1/$(tenant_id)s
    - require:
      - cmd: key-db-sync

cloudformation endpoint:
  keystone.endpoint_present:
    - name: heat-cfn
    - publicurl: http://{{ virl.openstack_public_ip }}:8000/v1
    - internalurl: http://{{ virl.controller_ip }}:8000/v1
    - adminurl: http://{{ virl.controller_ip }}:8000/v1
    - require:
      - cmd: key-db-sync
