{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}



/usr/local/bin/vinstall:
{% if not masterless %}
  file.managed:
    - source: salt://files/vinstall.py
    - user: virl
    - group: virl
    - mode: 0755
{% else %}
  file.symlink:
    - target: /srv/salt/virl/files/vinstall.py
    - mode: 0755
    - force: true
    - onlyif: 'test -e /srv/salt/virl/files/vinstall.py'
{% endif %}

{% if not masterless %}
/srv/salt/virl/host.sls:
  file.managed:
    - source: salt://virl/host.sls
    - makedirs: True
    - mode: 0755

/srv/salt/virl/ntp.sls:
  file.managed:
    - source: salt://virl/ntp.sls
    - makedirs: True
    - mode: 0755

{% endif %}
