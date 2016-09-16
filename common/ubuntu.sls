
include:
  - common.xenial-repo
  - common.pip
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

{% endif %}