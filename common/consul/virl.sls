
{% for each in ['/etc/consul.d/bootstrap/','/etc/consul.d/server/','/etc/consul.d/client/']%}
consul virl.conf:
  file.managed:
    - name: {{each}}virl.conf
    - source: salt://common/consul/files/virl.conf
    - user: consul
    - group: consul
{% endfor %}

consul:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: consul virl.conf
