
{% for each in ['/etc/consul.d/bootstrap/','/etc/consul.d/server/','/etc/consul.d/client/']%}
{{each}}salt_check.json:
  file.managed:
    - source: salt://common/consul/files/salt_check.json
    - user: consul
    - group: consul

{{each}}salt_service.json:
  file.managed:
    - source: salt://common/consul/files/salt_service.json
    - user: consul
    - group: consul
{% endfor %}

consul:
  service.running:
    - order: last
    - enable: True
    - reload: True

