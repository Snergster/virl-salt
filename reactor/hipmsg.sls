{% set id = data['id'] %}
{% set message = data['data']['message'] %}
{% set hater = data['data']['hater'] %}
{% set type = data['data']['type']  %}
{% set color = data['data']['color']  %}
{% if hater %}
sendmsg_run:
  runner.hipchat.send_message:
    - name: {{ hater }}
    - message: {{ message }}
    - color: {{ color }}
{% endif %}
