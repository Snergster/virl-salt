{% set uwmport = salt['grains.get']('virl user management', '19400') %}

cpu-checker:
  pkg.installed:
    - refresh: False

basic:
  pkg.installed:
    - order: 1
    - refresh: False
    - names:
      - emacs
      - python-dev
      - git
      - qemu-kvm
      - build-essential 
      - python-pip
      - python-configparser
      - ntp
      - openssh-server
      - crudini
      - zile
      - gcc
      - ntp
      - ntpdate
      - cpu-checker
      - openssl
      - apt-show-versions
      - htop
      - debconf-utils
      - apache2
      - libapache2-mod-wsgi
      - qemu-kvm
      - gedit
      - mtools
      - socat

/usr/local/bin/openstack-config:
  file.symlink:
    - target: /usr/bin/crudini
    - mode: 0755

/usr/local/bin/vinstall:
  file.managed:
    - source: salt://virl/files/vinstall.py
    - user: virl
    - group: virl
    - mode: 755

/usr/bin/telnet_front:
  file.managed:
    - source: salt://virl/files/install_scripts/telnet_front
    - mode: 755

/etc/modprobe.d/kvm-intel.conf:
  file.managed:
    - source: salt://virl/files/kvm-intel.conf
    - mode: 755

/home/virl/.virl.jpg:
  file.managed:
    - source: salt://virl/files/virl.jpg
    - user: virl
    - group: virl

/home/virl/orig.settings.ini:
  file.managed:
    - source: salt://virl/files/vsettings.ini
    - user: virl
    - group: virl
    - mode: 755

virlwebpages:
  file.recurse:
    - name: /var/www/html
    - source: salt://virl/files/virlweb
    - user: root
    - group: root
    - file_mode: 755

# base_index_pointer:
#   file.replace:
#     - name: /var/www/index.html
#     - pattern: 'UWMPORT'
#     - repl: '{{ uwmport }}'


