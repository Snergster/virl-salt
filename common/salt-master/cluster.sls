{% set publicport = salt['pillar.get']('virl:public_port', salt['grains.get']('public_port', 'eth0')) %}

include:
  - common.salt-master.no-auto-start

salt-master config:
  file.managed:
    - name: /etc/salt/master.d/cluster.conf
    - source: salt://common/salt-master/files/cluster.conf.jinja
    - makedirs: true
    - template: jinja

port block salt-master:
  file.blockreplace:
    - name: /etc/rc.local
    - marker_start: "# 004s"
    - marker_end: "# 004e"
    - content: |
             /sbin/iptables -A INPUT -p tcp --dport 4505:4506 -i {{ publicport }} -j DROP

/srv/salt:
  file.directory:
    - makedirs: true

/srv/pillar/top.sls:
  file.managed:
    - contents: |
        base:
          'compute1*':
            - compute1
          'compute2*':
            - compute2
          'compute3*':
            - compute3
          'compute4*':
            - compute4

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
