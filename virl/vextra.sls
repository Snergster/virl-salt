{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

vextra install and run:
  file.managed:
    - mode: 755
    - name: /usr/local/bin/vextra
    {% if masterless %}
    - source: /srv/salt/virl/files/vextra.py
    - source_hash: md5=f9a5f9197d6a2d5ab1ae8b0c436c9634
    {% else %}
    - source: "salt://virl/files/vextra.py"
    {% endif %}
  cmd.run:
    - name: /usr/local/bin/vextra
    - require:
      - file: vextra install and run
