
{% for each in ['/etc/consul.d/bootstrap/','/etc/consul.d/server/','/etc/consul.d/client/']%}
{{each}}virl_check.json:
  file.managed:
    - source: salt://common/consul/files/virl_check.json
    - user: consul
    - group: consul
{{each}}virl_service.json:
  file.managed:
    - source: salt://common/consul/files/virl_service.json
    - user: consul
    - group: consul
{% endfor %}

consul:
  service.running:
    - order: last
    - enable: True
    - reload: True

