{% set ifproxy = salt['grains.get']('proxy', 'False') %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

include:
  - common.ubuntu
  - virl.vinstall
  - openstack.repo
  - common.kvm

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
      - python-dulwich

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

{% if not masterless %}
vinstall wheels:
  file.recurse:
    - name: /tmp/wheels
    - source: salt://files/wheels
{% endif %}

{% for pyreq in 'wheel','envoy','docopt','sh','configparser>=3.3.0r2' %}
{{ pyreq }}:
  pip.installed:
    - require:
      - pkg: pip on the box
      - file: /usr/local/bin/vinstall
      {% if not masterless %}
      - file: vinstall wheels
      {% endif %}
    - use_wheel: True
    - pre_releases: True
    - no_deps: True
    {% if not masterless %}
    - no_index: True
    - find_links: "file:///tmp/wheels"
    {% endif %}
{% endfor %}

/usr/bin/telnet_front:
  {% if not masterless %}
  file.managed:
    - source: salt://virl/files/telnet_front
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/telnet_front
    - force: true
  {% endif %}
    - mode: 755

/etc/apparmor.d/local/telnet_front:
  {% if not masterless %}
  file.managed:
    - source: salt://virl/files/telnet_front.aa
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/telnet_front.aa
    - force: true
  {% endif %}
    - mode: 644
  cmd.wait:
    - name: service apparmor reload
    - watch:
      - file: /etc/apparmor.d/local/telnet_front


/etc/apparmor.d/libvirt/TEMPLATE:
  {% if not masterless %}
  file.managed:
    - source: salt://virl/files/libvirt.template
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/libvirt.template
    - force: true
  {% endif %}
    - makedirs: true
    - mode: 644
  cmd.wait:
    - name: service apparmor reload
    - watch:
      - file: /etc/apparmor.d/libvirt/TEMPLATE


/etc/modprobe.d/kvm-intel.conf:
  {% if not masterless %}
  file.managed:
    - source: salt://virl/files/kvm-intel.conf
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/kvm-intel.conf
    - force: true
  {% endif %}
    - mode: 755

/home/virl/.virl.jpg:
  {% if not masterless %}
  file.managed:
    - source: salt://virl/files/virl.jpg
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/virl.jpg
    - force: true
  {% endif %}
    - user: virl
    - group: virl

{% if not masterless %}
/etc/orig.virl.ini:
  file.managed:
    - source: salt://files/vsettings.ini
    - user: virl
    - group: virl
    - mode: 755
{% endif %}

/etc/init/failsafe.conf:
  {% if not masterless %}
  file.managed:
    - source: salt://virl/files/failsafe.conf
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/failsafe.conf
    - force: true
  {% endif %}
    - file_mode: 644

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


salt-minion nohold:
  file.absent:
    - name: /etc/apt/preferences.d/salt-minion
