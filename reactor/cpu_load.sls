{% set id = data['data']['id'] %}

{% if id %}
{% set cpu = data['data']['avg'] %}

sendmsg_run:
  local.hipchat.send_message:
    - tgt: {{ id }}
    - kwarg:
        message: cpu usage on {{ id }} is over threshold at {{ cpu }}
        color: yellow
        room_id: 1332718
        from_name: cpu_watcher
{% endif %}
