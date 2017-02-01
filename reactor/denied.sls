{% set id = data['id'] %}

{% if id %}
{% set removal = data['path'] %}
restart salt-master:
  local.file.remove:
    - tgt: {{ id }}
    - arg:
      - {{removal}}

sendmsg_run:
  local.hipchat.send_message:
    - tgt: {{ id }}
    - kwarg:
        message: Received deny creation on {{ id }} key {{ removal }}
        color: yellow
        room_id: 2026476
        from_name: deny_killer
{% endif %}
