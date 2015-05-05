{% set id = data['id'] %}
{% set user = data['data']['__pub_user'] %}
{% if id %}
simple state ex:
  local.virl_core.project_absent:
    - tgt: {{ id }}
    - arg:
      - {{user}}
{% endif %}
