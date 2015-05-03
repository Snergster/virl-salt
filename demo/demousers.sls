{% for user in ['odl001','odl002','odl003','odl004','odl005','sdn001','sdn002','sdn003','sdn004','sdn005','bgp001','bgp002','bgp003']%}
  {{user}}:
    user.present:
      - shell: /usr/sbin/nologin
      - createhome: False
      - password: $6$AlTBj1C0$5Zfl8QCXKrlxfgZ15YD4BdJiLf5HIWeL36ug9jJVU5YyDOHVfUhiBWBUkIOMbMqUBx6k8gHxwy/dgW/ARl.1N1
{% endfor %}

