{% set id = data['id'] %}
{% set message = data['message'] %}
{% set hater = data['hater'] %}
{% set type = data['type']  %}
{% set color = data['color']  %}
{% if hater %}
sendmsg_run:
  runner.hipchat.send_message:
    - name: {{ hater }}
    - message: {{ message }}
    - color: {{ color }}
{% endif %}
