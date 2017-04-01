
include:
  - common.pip
{% if not 'xenial' in salt['grains.get']('oscodename') %}
  - common.salt-minion.amd
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
      - vim
      - landscape-sysinfo

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
    - onlyif: grep /fd0 /etc/fstab

{% endif %}

turn off update message crap:
  cmd.run:
    - name: crudini --set /etc/update-manager/release-upgrades DEFAULT Prompt never
    - onlyif: test -f /etc/update-manager/release-upgrades

release-upgrade-available remove:
  file.absent:
    - name: /var/lib/update-notifier/release-upgrade-available
