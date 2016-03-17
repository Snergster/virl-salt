{% set compute1 = salt['grains.get']('compute1_hostname', 'compute1' ) %}
{% set compute2 = salt['grains.get']('compute2_hostname', 'compute2' ) %}
{% set compute3 = salt['grains.get']('compute3_hostname', 'compute3' ) %}
{% set compute4 = salt['grains.get']('compute4_hostname', 'compute4' ) %}

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

