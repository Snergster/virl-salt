{% set ifproxy = salt['grains.get']('proxy', 'False') %}

include:
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
      - curl
      - openssl
      - apt-show-versions
      - htop
      - debconf-utils
      - apache2
      - libapache2-mod-wsgi
      - mtools
      - socat
      - lxc

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

vinstall run:
  cmd.run:
    - name: /usr/local/bin/vinstall salt
    - onlyif: 'test -e /etc/virl.ini'
    - require:
      - file: /usr/local/bin/vinstall
      - pip: docopt

vinstall wheels:
  file.recurse:
    - name: /tmp/wheels
    - source: salt://files/wheels

{% for pyreq in 'wheel','envoy','docopt','sh','configparser>=3.3.0r2' %}
{{ pyreq }}:
  pip.installed:
    - require:
      - pkg: pip on the box
      - file: /usr/local/bin/vinstall
      - file: vinstall wheels
    - use_wheel: True
    - no_index: True
    - pre_releases: True
    - no_deps: True
    - find_links: "file:///tmp/wheels"
{% endfor %}

/usr/bin/telnet_front:
  file.managed:
    - source: salt://files/install_scripts/telnet_front
    - mode: 755

/etc/apparmor.d/local/telnet_front:
  file.managed:
    - source: salt://files/install_scripts/telnet_front.aa
    - mode: 644

/etc/apparmor.d/libvirt/TEMPLATE:
  file.managed:
    - source: salt://files/install_scripts/libvirt.template
    - makedirs: true
    - mode: 644

kvm doublecheck:
  file.managed:
    - name: /usr/bin/kvm
    - onlyif: ls /usr/bin/kvm.real
    - source: "salt://files/install_scripts/kvm"
    - mode: 0755

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

salt-minion nohold:
  file.absent:
    - name: /etc/apt/preferences.d/salt-minion
