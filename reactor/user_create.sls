{% set id = data['id'] %}
{% set user = data['data']['user'] %}
{% if 'bgp' in user %}
bgp tenant state ex:
  local.virl_core.project_present:
    - tgt: {{ id }}
    - arg:
      - {{user}}
      - description='bgp demo'
      - quota_vcpus=10
      - quota_instances=10

bgp specific image:
  local.cmd.run:
    - tgt: {{ id }}
    - arg:
      - salt-call state.sls virl.routervms.iosv

bgp password reset:
  local.virl_core.user_present:
    - tgt: {{ id }}
    - arg:
      - {{user}}
      - password={{ user }}
      - project={{ user }}
      - role='_member_'




{% elif 'odl' in user %}
simple state ex:
  local.virl_core.project_present:
    - tgt: {{ id }}
    - arg:
      - {{user}}
      - description='odl demo'
      - quota_vcpus=10
      - expires=2
      - quota_instances=10

simple pass fix:
  local.virl_core.user_present:
    - require:
      - local.virl_core: simple pass fix
    - tgt: {{ id }}
    - arg:
      - {{user}}
      - password={{ user }}
      - project={{ user }}
      - role='_member_'

odl specific image:
  local.cmd.run:
    - tgt: {{ id }}
    - arg:
      - salt-call state.sls virl.routervms.iosv

{% elif 'salt' in user %}
simple state ex:
  local.cmd.run:
    - tgt: {{ id }}
    - arg:
      - virluser="{{user}}" virlpass="{{user}}" virlvcpu=10 virlexpire=2 virlinstances=10 salt-call state.sls virl.user

salt specific image:
  local.cmd.run:
    - tgt: {{ id }}
    - arg:
      - salt-call state.sls virl.routervms.iosv

{% endif %}
