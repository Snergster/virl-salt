{% set ifproxy = salt['grains.get']('proxy', 'False') %}

include:
  - common.pip
  - common.uptodate
  - common.ubuntu
  - virl.vinstall

mypkgs:
  pkg.installed:
    - skip_verify: True
    - refresh: False
    - pkgs:
      - debconf-utils
      - dkms
      - kexec-tools
      - qemu-kvm
      - gcc
      - cpu-checker
      - openssl
      - apt-show-versions
      - htop
      - debconf-utils
      - apache2
      - libapache2-mod-wsgi
      - mtools
      - socat

/etc/apt/sources.list.d/cisco-openstack-mirror_icehouse.list:
  file.managed:
    - source: salt://files/cisco-openstack-mirror_icehouse.list


/etc/apt/preferences.d/cisco-openstack:
  file.managed:
    - source: salt://files/cisco-openstack-preferences

/tmp/cisco-openstack.key:
  file.managed:
    - source: salt://files/cisco-openstack.key
  cmd.wait:
    - name: apt-key add /tmp/cisco-openstack.key
    - cwd: /tmp
    - watch:
      - file: /tmp/cisco-openstack.key

qemu hold:
  apt.held:
    - name: qemu-kvm
    - require:
      - pkg: mypkgs

linuxbridge hold:
  apt.held:
    - name: neutron-plugin-linuxbridge-agent
    - onlyif: 'test -e /usr/bin/neutron-linuxbridge-agent'

{% for pyreq in 'wheel','envoy','docopt','sh','configparser>=3.3.0r2' %}
{{ pyreq }}:
  pip.installed:
    - require:
      - pkg: pip on the box
      - file: /usr/local/bin/vinstall
    {% if ifproxy == True %}
    {% set proxy = salt['grains.get']('http proxy', 'None') %}
    - proxy: {{ proxy }}
    {% endif %}
{% endfor %}

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
