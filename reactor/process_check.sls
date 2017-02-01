{% set id = data['id'] %}

{% if 'salt-master' in data['data'] %}
{% set running_status = data['salt-master']['running'] %}
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
        room_id: 1552751
        from_name: master_watch
{% endif %}
{% if 'proftpd' in data['data'] %}
{% set running_status = data['proftpd']['running'] %}
restart proftpd:
  local.service.start:
    - tgt: {{ id }}
    - arg:
      - proftpd

sendmsg_run proftp:
  local.hipchat.send_message:
    - tgt: {{ id }}
    - kwarg:
        message: proftpd status on {{ id }} is {{ running_status }}
        {% if running_status %}
        color: green
        {% else %}
        color: red
        {% endif %}
        room_id: 1332718
        from_name: proftp_watch
{% endif %}

