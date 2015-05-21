{% if salt['pillar.get']('reactor') %}
/etc/salt/master.d/reactor.conf:
  file.managed:
    - template: jinja
    - source: salt://common/salt-master/files/reactor.conf
{% endif %}
