
include:
{% if not 'xenial' in salt['grains.get']('oscodename') %}
  - common.pip
{% endif %}
  - common.distuptodate

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


saltstack repo to trusted:
  file.replace:
    - name: /etc/apt/sources.list.d/saltstack.list
    - pattern: deb https
    - repl: deb [trusted=yes] https

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
