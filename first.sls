{% set uwmport = salt['grains.get']('virl_user_management', '19400') %}
{% set proxy = salt['grains.get']('proxy', 'False') %}
{% set httpproxy = salt['grains.get']('http_proxy', 'https://proxy-wsa.esl.cisco.com:80/') %}


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
      - mtools
      - socat

pip install:
  pkg.installed:
    - order: 2
    - name: python-pip


/usr/local/bin/openstack-config:
  file.symlink:
    - target: /usr/bin/crudini
    - mode: 0755

/usr/local/bin/vinstall:
  file.managed:
    - source: salt://files/vinstall.py
    - user: virl
    - group: virl
    - mode: 755

/usr/bin/telnet_front:
  file.managed:
    - source: salt://files/install_scripts/telnet_front
    - mode: 755

/etc/modprobe.d/kvm-intel.conf:
  file.managed:
    - source: salt://files/kvm-intel.conf
    - mode: 755

/home/virl/.virl.jpg:
  file.managed:
    - source: salt://files/virl.jpg
    - user: virl
    - group: virl

/etc/orig.virl.ini:
  file.managed:
    - source: salt://files/vsettings.ini
    - user: virl
    - group: virl
    - mode: 755

/var/www/download:
  file.directory:
    - order: 1
    - mode: 755
    - makedirs: True

/var/www/html:
  file.directory:
    - order: 1
    - mode: 755
    - makedirs: True


virlwebpages:
  file.recurse:
    - name: /var/www/html
    - source: salt://files/virlweb
    - user: root
    - group: root
    - file_mode: 755


/etc/init/failsafe.conf:
  file.managed:
    - file_mode: 644
    - source: "salt://files/failsafe.conf"
