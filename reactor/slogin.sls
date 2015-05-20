{% set id = data['data']['id'] %}
{% set user = data['data']['user'] %}
{% set hostname = data['data']['hostname'] %}
{% if user %}


sendmsg_run:
  local.hipchat.send_message:
    - tgt: {{ id }}
    - kwarg:
        message: Successful login on {{ id }} from user {{ user }} source {{hostname}}
        color: yellow
        room_id: 1332718
        from_name: login
{% endif %}
