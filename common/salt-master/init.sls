{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}

include:
  - common.salt-master.gitpython
  - common.salt-master.psutil

salt-master install:
  file.managed:
    - name: /home/ubuntu/install_salt.sh
    - mode: 0755
    - source: "salt://install_salt.sh"
  cmd.run:
      - name: /home/ubuntu/install_salt.sh -M -X git 2015.5
      - unless:
        - ls /usr/bin/salt-master

pip backup only:
  pkg.installed:
    - name: python-pip
    - unless: ls /usr/bin/pip

M2Crypto backup:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - upgrade: True
    - name: M2Crypto
    - require:
      - pkg: pip backup only


msgpack-python backup:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - name: msgpack-python
    - upgrade: True
    - require:
      - pkg: pip backup only

/etc/salt/pki:
  file.directory:
    - makedirs: true
  mount.mounted:
    - device: ramdisk
    - fstype: tmpfs
    - opts: rw,relatime
    - dump: 0
    - pass_num: 0
    - require:
      - file: /etc/salt/pki

/srv/pillar:
  file.directory:
    - makedirs: true
  mount.mounted:
    - device: ramdisk
    - fstype: tmpfs
    - opts: rw,relatime
    - dump: 0
    - pass_num: 0
    - require:
      - file: /srv/pillar

/var/cache/salt/minion/files/base/pillar:
  file.directory:
    - makedirs: true
  mount.mounted:
    - device: ramdisk
    - fstype: tmpfs
    - opts: rw,relatime
    - dump: 0
    - pass_num: 0
    - require:
      - file: /var/cache/salt/minion/files/base/pillar

