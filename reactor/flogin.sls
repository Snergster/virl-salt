{% set id = data['id'] %}

{% if id %}
{% set user = data['user'] %}

sendmsg_run:
  local.hipchat.send_message:
    - tgt: {{ id }}
    - kwarg:
        message: Failed login on {{ id }} from user {{ user }}
        color: yellow
        room_id: 2026504
        from_name: login
        notify: True
{% endif %}
