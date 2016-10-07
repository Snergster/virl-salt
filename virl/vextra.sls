{% set packet = salt['pillar.get']('virl:packet', salt['grains.get']('packet', False )) %}


{% if 'xenial' in salt['grains.get']('oscodename') %}

include:
  - common.pip

{% endif %}


docopt prereq:
  pip.installed:
    - name: docopt

vextra install and run:
  file.managed:
    - mode: 0755
    - name: /usr/local/bin/vextra
    - source: "salt://virl/files/vextra.py"
{% if not packet %}
  cmd.run:
    - name: /usr/local/bin/vextra
    - onlyif: test -e /etc/virl.ini
    - require:
      - file: vextra install and run
      - pip: docopt prereq
{% endif %}

vsalt install and run:
  file.managed:
    - mode: 0755
    - name: /usr/local/bin/vsalt
    - source: "salt://virl/files/vsalt"
