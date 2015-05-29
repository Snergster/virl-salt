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
    - order: last
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
  local.virl_core.project_present:
    - tgt: {{ id }}
    - arg:
      - {{user}}
      - description='salt demo'
      - quota_vcpus=10
      - expires=3
      - quota_instances=10

simple pass fix:
  local.virl_core.user_present:
    - tgt: {{ id }}
    - arg:
      - {{user}}
      - password={{ user }}
      - project={{ user }}
      - role='_member_'

salt specific image:
  local.cmd.run:
    - tgt: {{ id }}
    - arg:
      - salt-call state.sls virl.routervms.iosv

{% endif %}
