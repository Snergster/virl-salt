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

/srv/pillar/virl:
  file.directory:
    - makedirs: true

/srv/salt:
  file.directory:
    - makedirs: true

/srv/salt/pillar/top.sls:
  file.managed:
    - contents: |
      base:
        '*':
          - virl

/srv/salt/pillar/virl/init.sls:
  file.managed:
    - template: jinja
    - source: salt://common/salt-master/files/cluster.ini.jinja
