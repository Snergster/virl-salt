
{% for each in ['/etc/consul.d/bootstrap/','/etc/consul.d/server/','/etc/consul.d/client/']%}
{{each}}virl_check.json:
  file.managed:
    - source: salt://common/consul/files/virl_check.json
    - template: jinja
    - user: consul
    - group: consul
{{each}}virl_service.json:
  file.managed:
    - source: salt://common/consul/files/virl_service.json
    - template: jinja
    - user: consul
    - group: consul
{{each}}virl_watches.json:
  file.managed:
    - source: salt://common/consul/files/virl_watches.json
    - template: jinja
    - user: consul
    - group: consul
{% endfor %}

virl consul restart:
  cmd.run:
    - name: /usr/sbin/service consul restart

