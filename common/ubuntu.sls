{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}

include:
  - common.pip
  - common.distuptodate
  - common.rc-local
  - common.ssh.keygen

commonpkgs:
  pkg.installed:
    - refresh: False
    - pkgs:
      - build-essential
      - python-dev
      - python-dateutil
      - git
      - ntp
      - traceroute
      - ntpdate
      - zile
      - curl
      - sshpass
      - openssh-server
      - crudini
      - unzip
      - at
      - swig
      - libssl-dev
      - htop
      - gcc
      - bc


/usr/local/bin/openstack-config:
  file.symlink:
    - target: /usr/bin/crudini
    - mode: 0755
    - require:
      - pkg: commonpkgs

/srv/salt:
  file.directory:
    - dir_mode: 755
    - makedirs: True

salt-master unhold:
  module.run:
    - name: pkg.unhold
    - m_name: salt-master
    - onlyif: ls /usr/bin/salt-master

salt-minion unhold:
  module.run:
    - name: pkg.unhold
    - m_name: salt-minion
    - onlyif: ls /usr/bin/salt-minion

salt-common unhold:
  module.run:
    - name: pkg.unhold
    - m_name: salt-common
    - onlyif: ls /usr/bin/salt-minion

/etc/apt/apt.conf.d/99force-ipv4:
  file.managed:
    - makedirs: true
    - contents: |
        Acquire::ForceIPv4 "true";
