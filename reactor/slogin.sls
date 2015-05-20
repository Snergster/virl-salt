{% set id = data['data']['id'] %}
{% set user = data['data']['user'] %}
{% if user %}


sendmsg_run:
  local.hipchat.send_message:
    - tgt: {{ id }}
    - kwarg:
        message: Successful login on {{ id }} from user {{ user }}
        color: yellow
        room_id: 1332718
        from_name: login
{% endif %}
