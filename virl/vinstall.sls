{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}



/usr/local/bin/vinstall:
{% if masterless == false %}
  file.managed:
    - source: salt://virl/files/vinstall.py
    - user: virl
    - group: virl
    - mode: 0755
{% else %}
  file.copy:
    - source: /srv/salt/virl/files/vinstall.py
    - mode: 0755
    - force: true
    - onlyif: 'test -e /srv/salt/virl/files/vinstall.py'
{% endif %}

{% if masterless == false %}
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

/srv/salt/virl/files/ntp.conf:
  file.managed:
    - source: salt://virl/files/ntp.conf
    - makedirs: True
    - mode: 0755

/srv/salt/host.sls:
  file.managed:
    - source: salt://host.sls
    - makedirs: True
    - mode: 0755

/srv/salt/virl/files/virl.jpg:
  file.managed:
    - source: salt://virl/files/virl.jpg
    - makedirs: True
    - mode: 0755

{% endif %}
