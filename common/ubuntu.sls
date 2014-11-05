include:
  - common.pip
  - common.uptodate

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
      - emacs
      - openssh-server
      - crudini
      - lxc

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

    