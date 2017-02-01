{% set id = data['id'] %}

{% if id %}
{% set mount = data['mount'] %}
{% set disk = data['diskusage'] %}


sendmsg_run:
  local.hipchat.send_message:
    - tgt: {{ id }}
    - kwarg:
        message: Disk usage on {{ id }} on mount {{ mount }} is at {{ disk }}
        color: yellow
        room_id: 1552753
        from_name: disk_filler
        notify: True
{% endif %}
