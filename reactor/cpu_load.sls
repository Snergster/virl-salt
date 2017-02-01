{% set id = data['id'] %}

{% if id %}
{% set cpu = data['avg'] %}

sendmsg_run:
  local.hipchat.send_message:
    - tgt: {{ id }}
    - kwarg:
        message: cpu usage on {{ id }} is over threshold at {{ cpu }}
        color: yellow
        room_id: 1552751
        from_name: cpu_watcher
{% endif %}
