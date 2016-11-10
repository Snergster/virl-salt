{% set publicport = salt['pillar.get']('virl:public_port', salt['grains.get']('public_port', 'eth0')) %}
{% set packet = salt['pillar.get']('virl:packet', salt['grains.get']('packet', False )) %}
{% set controller = salt['pillar.get']('virl:this_node_is_the_controller', salt['grains.get']('this_node_is_the_controller', True)) %}

include:
  - common.salt-master.cluster-config
  - common.salt-master.cluster-key
  - virl.hostname.cluster

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
             /sbin/iptables -I INPUT 1 -s 10/8 -p tcp --dport 4505:4506 -j ACCEPT
             /sbin/iptables -I INPUT 2 -s 172.16/16 -p tcp --dport 4505:4506 -j ACCEPT
             /sbin/iptables -I INPUT 3 -p tcp --dport 4505:4506 -i {{ publicport }} -j DROP
{% else %}

port block salt-master:
  file.blockreplace:
    - name: /etc/rc.local
    - marker_start: "# 004s"
    - marker_end: "# 004e"
    - content: |
             /sbin/iptables -I INPUT 1 -p tcp --dport 4505:4506 -i {{ publicport }} -j DROP

{% endif %}

/srv/salt:
  file.directory:
    - makedirs: true

/srv/pillar:
  file.directory:
    - makedirs: true

compute filter for cluster controller:
  openstack_config.present:
    - filename: /etc/nova/nova.conf
    - section: 'DEFAULT'
    - parameter: 'scheduler_default_filters'
    - value: 'AllHostsFilter,ComputeFilter'
    - onlyif: test -e /etc/nova/nova.conf

{% if controller %}

/etc/init/salt-master.conf:
  file.managed:
    - source: salt://common/salt-master/files/salt-master.conf

remove salt-master override:
  file.absent:
    - name: /etc/init/salt-master.override

verify salt-master enabled:
  service.enabled:
    - name: salt-master
    - require:
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

{% endif %}

open rabbitmq guest security:
  file.managed:
    - name: /etc/rabbitmq/rabbitmq.config
    - makedirs: True
    - contents: |
        [{rabbit, [{loopback_users, []}]}].


