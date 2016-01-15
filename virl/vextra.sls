{% set packet = salt['pillar.get']('virl:packet', salt['grains.get']('packet', False )) %}
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
    - require:
      - file: vextra install and run
      - pip: docopt prereq
{% endif %}

vsalt install and run:
  file.managed:
    - mode: 0755
    - name: /usr/local/bin/vsalt
    - source: "salt://virl/files/vsalt"
