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
      - zile
      - gedit
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
      - configobj
      - six
      - Mako
      - MarkupSafe
      - certifi
      - backports.ssl_match_hostname
      - netaddr
      - networkx
      - PyYAML
      - tornado == 3.0.1
      - ipaddr
      - flask-sqlalchemy
      - Flask
      - Flask_Login
      - Flask_RESTful
      - Flask_WTF
      - itsdangerous
      - Jinja2
      - lxml
      - MarkupSafe
      - mock
      - requests
      - paramiko
      - pycrypto
      - simplejson
      - sqlalchemy
      - websocket_client
      - Werkzeug
      - wsgiref
      - WTForms



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

/home/virl/orig.settings.ini:
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
    # - require:
    #   - file: /var/www/html

# base_index_pointer:
#   file.replace:
#     - name: /var/www/index.html
#     - pattern: 'UWMPORT'
#     - repl: '{{ uwmport }}'
