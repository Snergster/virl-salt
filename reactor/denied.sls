{% set id = data['data']['id'] %}

{% if id %}
{% set removal = data['data']['path'] %}
restart salt-master:
  local.file.removed:
    - tgt: {{ id }}
    - arg:
      - {{removal}}

sendmsg_run:
  local.hipchat.send_message:
    - tgt: {{ id }}
    - kwarg:
        message: Received deny creation on {{ id }} key {{ removal }}
        color: yellow
        room_id: 1332718
        from_name: deny_killer
{% endif %}
