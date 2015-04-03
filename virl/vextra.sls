{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

vextra install and run:
  file.managed:
    - mode: 755
    - name: /usr/local/bin/vextra
    {% if masterless %}
    - source: /srv/salt/virl/files/vextra.py
    - source_hash: md5=6b2bf8fe6d76fe48b5cf40813e982069
    {% else %}
    - source: "salt://virl/files/vextra.py"
    {% endif %}
  cmd.run:
    - name: /usr/local/bin/vextra
    - require:
      - file: vextra install and run
