{% set id = data['id'] %}
{% set state = data['data']['state'] %}
{% if id %}
simple state ex:
  local.state.sls:
    - tgt: {{ id }}
    - arg:
      - {{state}}
{% endif %}
