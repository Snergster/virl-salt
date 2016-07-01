{% from "virl.jinja" import virl with context %}

{% if virl.proxy %}
http_proxy:
  environ.setenv:
    - value: {{ virl.http_proxy }}

https_proxy:
  environ.setenv:
    - value: {{ virl.http_proxy }}

{% endif %}

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
  cmd.run:
    - name: 'pip install pip==7.1.2'


python-pip:
  pkg.purged:
    - name: python-pip
    - hold: True
    - require:
      - cmd: pip hard up


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

python-pip mirror defaults:
  file.managed:
    - name: /etc/pip.conf
{% if virl.pypi_mirror %}
    - contents: |
        [global]
        cache-dir = /tmp
        disable-pip-version-check = true
        index-url = {{ virl.pypi_mirror_index }}
        [install]
        trusted-host = {{ virl.pypi_mirror_location }}

{% else %}
    - contents: |
        [global]
        cache-dir = /tmp
        disable-pip-version-check = true

{% endif %}
