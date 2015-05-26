
{% for each in ['/etc/consul.d/boostrap/','/etc/consul.d/server/','/etc/consul.d/client/']%}
{{each}}virl.conf:
  file.managed:
    - source: salt://common/consul/files/virl.conf
    - user: consul
    - group: consul
{% endfor %}