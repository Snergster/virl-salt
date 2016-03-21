{% set compute1 = salt['grains.get']('compute1_hostname', 'compute1' ) %}
{% set compute2 = salt['grains.get']('compute2_hostname', 'compute2' ) %}
{% set compute3 = salt['grains.get']('compute3_hostname', 'compute3' ) %}
{% set compute4 = salt['grains.get']('compute4_hostname', 'compute4' ) %}
{% set compute2_active = salt['pillar.get']('virl:compute2_active', salt['grains.get']('compute2_active', False )) %}
{% set compute3_active = salt['pillar.get']('virl:compute3_active', salt['grains.get']('compute3_active', False )) %}
{% set compute4_active = salt['pillar.get']('virl:compute4_active', salt['grains.get']('compute4_active', False )) %}

/srv/pillar/top.sls:
  file.managed:
    - makedirs: true
    - contents: |
        base:
          '*':
            - users
          'compute1*':
            - compute1
          'compute2*':
            - compute2
          'compute3*':
            - compute3
          'compute4*':
            - compute4

/srv/pillar/users/init.sls:
  file.managed:
    - makedirs: true
    - template: jinja
    - source: salt://common/salt-master/files/virluser.jinja

/srv/pillar/compute1/init.sls:
  file.managed:
    - makedirs: true
    - template: jinja
    - source: salt://common/salt-master/files/compute1.ini.jinja

/srv/pillar/compute2/init.sls:
  file.managed:
    - makedirs: true
    - template: jinja
    - source: salt://common/salt-master/files/compute2.ini.jinja

/srv/pillar/compute3/init.sls:
  file.managed:
    - makedirs: true
    - template: jinja
    - source: salt://common/salt-master/files/compute3.ini.jinja

/srv/pillar/compute4/init.sls:
  file.managed:
    - makedirs: true
    - template: jinja
    - source: salt://common/salt-master/files/compute4.ini.jinja

  {% if compute4_active %}

add up to cluster4 to std:
  cmd.run:
    - name: crudini --set /etc/virl/common.cfg cluster computes '{{compute1}},{{compute2}},{{compute3}},{{compute4}}'
    - onlyif: test -e /etc/virl/common.cfg

  {% elif compute3_active %}

add up to cluster3 to std:
  cmd.run:
    - name: crudini --set /etc/virl/common.cfg cluster computes '{{compute1}},{{compute2}},{{compute3}}'
    - onlyif: test -e /etc/virl/common.cfg

  {% elif compute2_active %}

add up to cluster2 to std:
  cmd.run:
    - name: crudini --set /etc/virl/common.cfg cluster computes '{{compute1}},{{compute2}}'
    - onlyif: test -e /etc/virl/common.cfg

  {% else %}

add only cluster1 to std:
  cmd.run:
    - name: crudini --set /etc/virl/common.cfg cluster computes '{{compute1}}'
    - onlyif: test -e /etc/virl/common.cfg

  {% endif %}

point std at key if it exists:
  cmd.run:
    - name: crudini --set /etc/virl/common.cfg cluster ssh_key '~virl/.ssh/id_rsa'
    - onlyif:
      - test -e ~virl/.ssh/id_rsa.pub
      - test -e /etc/virl/common.cfg
