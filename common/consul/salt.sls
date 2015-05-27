
{% for each in ['/etc/consul.d/bootstrap/','/etc/consul.d/server/','/etc/consul.d/client/']%}
{{each}}salt.conf:
  file.managed:
    - source: salt://common/consul/files/salt.conf
    - user: consul
    - group: consul
{% endfor %}

consul:
  service.running:
    - order: last
    - enable: True
    - reload: True

