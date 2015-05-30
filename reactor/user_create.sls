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
      - expires=2
      - quota_instances=15
      - user_password= {{user}}

bgp specific image:
  local.cmd.run:
    - tgt: {{ id }}
    - arg:
      - salt-call state.sls virl.routervms.iosv




{% elif 'odl' in user %}
simple state ex:
  local.virl_core.project_present:
    - tgt: {{ id }}
    - arg:
      - {{user}}
      - description='odl demo'
      - quota_vcpus=10
      - expires=8
      - quota_instances=8
      - user_password= {{user}}


{% elif 'salt' in user %}

simple state ex:
  local.virl_core.project_present:
    - tgt: {{ id }}
    - arg:
      - {{user}}
      - description='salt demo'
      - quota_vcpus=10
      - expires=2
      - quota_instances=10
      - user_password= {{user}}

odl specific image:
  local.cmd.run:
    - tgt: {{ id }}
    - arg:
      - salt-call state.sls virl.routervms.iosv


{% endif %}
