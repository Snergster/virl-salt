trust-salt:
  file.replace:
    - name: /etc/apt/sources.list.d/saltstack.list
    - pattern: deb https
    - repl: deb [trusted=yes] https

baseline-packages:
  pkg.installed:
    - refresh: False
    - pkgs:
      - build-essential
      - python-dev
      - python-dateutil
      - python-mysqldb
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
      - virt-what
      - vim

/srv/salt:
  file.directory:
    - dir_mode: 755
    - makedirs: True
    - user: vps
    - group: adm

/srv/salt2:
  file.directory:
    - dir_mode: 755
    - makedirs: True
    - user: vps
    - group: adm    

/etc/apt/apt.conf.d/99force-ipv4:
  file.managed:
    - makedirs: true
    - contents: |
        Acquire::ForceIPv4 "true";

{% if 'xenial' in salt['grains.get']('oscodename') %}

floppy remove:
  file.comment:
    - name: /etc/fstab
    - regex: ^/dev/fd0
    - onlyif: grep /fd0 /etc/fstab

{% endif %}
