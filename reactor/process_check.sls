{% set id = data['data']['id'] %}

{% if 'salt-master' in data['data'] %}
{% set running_status = data['data']['salt-master']['running'] %}
restart salt-master:
  local.service.start:
    - tgt: {{ id }}
    - arg:
      - salt-master

sendmsg_run:
  local.hipchat.send_message:
    - tgt: {{ id }}
    - kwarg:
        message: salt-master status on {{ id }} is {{ running_status }}
        {% if running_status %}
        color: green
        {% else %}
        color: red
        {% endif %}
        room_id: 1332718
        from_name: master_watch
{% endif %}
