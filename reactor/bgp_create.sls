{% set id = data['id'] %}
{% set user = data['data']['__pub_user'] %}
{% if id %}
simple state ex:
  local.virl_core.project_present:
    - tgt: {{ id }}
    - arg:
      - {{user}}
      - description='fool node'
      - quota_vcpus=10
      - quota_instances=10

simple pass fix:
  local.virl_core.user_present:
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

{% endif %}
