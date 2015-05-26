
{% for each in ['/etc/consul.d/bootstrap/','/etc/consul.d/server/','/etc/consul.d/client/']%}
consul salt.conf:
  file.managed:
    - name: {{each}}salt.conf
    - source: salt://common/consul/files/salt.conf
    - user: consul
    - group: consul
{% endfor %}

consul:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: consul salt.conf
