{% set ifproxy = salt['grains.get']('proxy', 'False') %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

include:
  - common.ubuntu
  - virl.vinstall
  - openstack.repo
  - common.kvm
  - virl.scripts

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

qemu common virl hold:
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
      - pip: envoy
      - pip: sh
      - pip: 'configparser>=3.3.0r2'

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


download dir exists:
  file.directory:
    - name: /var/www/download
    - order: 1
    - mode: 755
    - makedirs: True

html dir exists:
  file.directory:
    - name: /var/www/html
    - order: 1
    - mode: 755
    - makedirs: True


salt-minion nohold:
  file.absent:
    - name: /etc/apt/preferences.d/salt-minion

/proc/sys/kernel/numa_balancing:
  cmd.run:
    - name: echo 0 > /proc/sys/kernel/numa_balancing
    - onlyif: grep 1 /proc/sys/kernel/numa_balancing
