{% set public_ip = salt['grains.get']('public_ip', '127.0.1.1') %}
{% set uwmpassword = salt['pillar.get']('virl:uwmadmin_password', salt['grains.get']('uwmadmin_password', 'password')) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}


include:
  - openstack.keystone.install



Keystone tenants:
  keystone.tenant_present:
    - require:
      - cmd: key-db-sync
    - names:
      - admin
      - service
      - uwmadmin

Keystone roles:
  keystone.role_present:
    - names:
      - admin
      - Member
      - heat_stack_user

admin:
  keystone.user_present:
    - password: {{ ospassword }}
    - email: admin@domain.com
    - roles:
        admin:   # tenants
          - admin  # roles
        service:
          - admin
          - Member
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles


uwmadmin:
  keystone.user_present:
    - password: {{ uwmpassword }}
    - email: uwmadmin@domain.com
    - tenant: uwmadmin
    - roles:
        uwmadmin:
          - admin
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles

nova:
  keystone.user_present:
    - password: {{ ospassword }}
    - email: nova@domain.com
    - tenant: service
    - roles:
        service:
          - admin
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles

neutron:
  keystone.user_present:
    - password: {{ ospassword }}
    - email: neutron@domain.com
    - tenant: service
    - roles:
        service:
          - admin
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles

glance:
  keystone.user_present:
    - password: {{ ospassword }}
    - email: glance@domain.com
    - tenant: service
    - roles:
        service:
          - admin
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles

cinder:
  keystone.user_present:
    - password: {{ ospassword }}
    - email: cinder@domain.com
    - tenant: service
    - roles:
        service:
          - admin
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles

heat:
  keystone.user_present:
    - password: {{ ospassword }}
    - email: heat@domain.com
    - tenant: service
    - roles:
        service:
          - admin
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles

nova service:
  keystone.service_present:
    - name: nova
    - service_type: compute
    - description: OpenStack Compute Service
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles

cinder service:
  keystone.service_present:
    - name: cinder
    - service_type: volume
    - description: OpenStack storage Service
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles

cinderv2 service:
  keystone.service_present:
    - name: cinderv2
    - service_type: volumev2
    - description: OpenStack storage Service v2
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles

heat service:
   keystone.service_present:
     - name: heat
     - service_type: orchestration
     - description: Orchestration
     - require:
       - keystone: Keystone tenants
       - keystone: Keystone roles

heat-cfn service:
   keystone.service_present:
     - name: heat-cfn
     - service_type: cloudformation
     - description: Orchestration CloudFormation
     - require:
       - keystone: Keystone tenants
       - keystone: Keystone roles

neutron service:
  keystone.service_present:
    - name: neutron
    - service_type: network
    - description: Neutron Service
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles

glance service:
  keystone.service_present:
    - name: glance
    - service_type: image
    - description: Glance Image Service
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles

keystone service:
  keystone.service_present:
    - name: keystone
    - service_type: identity
    - description: Keystone Identity Service
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles
