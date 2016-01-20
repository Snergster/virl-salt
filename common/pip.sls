{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set packet = salt['pillar.get']('virl:packet', salt['grains.get']('packet', False )) %}

pip on the box:
  pkg.installed:
    - name: python-pip
    - refresh: True
    - aggregate: False
    - unless: ls /usr/local/bin/pip
    - require:
      - file: remove ugly hold

remove ugly hold:
  file.absent:
    - name: /etc/apt/preferences.d/python-pip
    - unless: ls /usr/local/bin/pip


pip hard up:
  pip.installed:
    - name: pip < 8
    {% if proxy == true %}
    - proxy: {{ http_proxy }}
    {% endif %}
    - upgrade: True


python-pip:
  pkg.purged:
    - name: python-pip
    - hold: True
    - require:
      - pip: pip hard up


pip symlink:
  file.symlink:
    - name: /usr/bin/pip
    - target: /usr/local/bin/pip
    - mode: 0755
    - require:
      - pkg: python-pip
    - onlyif:
      - 'test -e /usr/local/bin/pip'
      - 'test ! -e /usr/bin/pip'


python-pip ugly hold:
  file.managed:
    - name: /etc/apt/preferences.d/python-pip
    - require:
      - pkg: python-pip
    - contents: |
        Package: python-pip
        Pin: release *
        Pin-Priority: -1

python-pip trashy defaults:
  file.managed:
    - name: /etc/pip.conf
    - contents: |
        [global]
        cache-dir = /tmp
        disable-pip-version-check = true


