{% set publicport = salt['pillar.get']('virl:public_port', salt['grains.get']('public_port', 'eth0')) %}
{% set packet = salt['pillar.get']('virl:packet', salt['grains.get']('packet', False )) %}

include:
  - common.salt-master.cluster-config

salt-master config:
  file.managed:
    - name: /etc/salt/master.d/cluster.conf
    - source: salt://common/salt-master/files/cluster.conf.jinja
    - makedirs: true
    - template: jinja

{% if packet %}

port block salt-master:
  file.blockreplace:
    - name: /etc/rc.local
    - marker_start: "# 004s"
    - marker_end: "# 004e"
    - content: |
             /sbin/iptables -A INPUT -s 10/8 -p tcp --dport 4505:4506 -j ACCEPT
             /sbin/iptables -A INPUT -p tcp --dport 4505:4506 -i {{ publicport }} -j DROP
{% else %}

port block salt-master:
  file.blockreplace:
    - name: /etc/rc.local
    - marker_start: "# 004s"
    - marker_end: "# 004e"
    - content: |
             /sbin/iptables -A INPUT -p tcp --dport 4505:4506 -i {{ publicport }} -j DROP

{% endif %}

/srv/salt:
  file.directory:
    - makedirs: true

/srv/pillar:
  file.directory:
    - makedirs: true

/etc/init/salt-master:
  file.managed:
    - source: salt://common/salt-master/files/salt-master.conf

remove salt-master override:
  file.absent:
    - name: /etc/init/salt-master.override

verify salt-master enabled:
  service.enabled:
    - name: salt-master
    - onchanges:
      - file: remove salt-master override

salt-master restarting for config:
  service.running:
    - name: salt-master
    - watch:
      - file: salt-master config
      - file: /srv/pillar/compute1/init.sls
      - file: /srv/pillar/compute2/init.sls
      - file: /srv/pillar/compute3/init.sls
      - file: /srv/pillar/compute4/init.sls

