{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

vsalt install and run:
  file.managed:
    - mode: 755
    - name: /usr/local/bin/vsalt
    {% if masterless %}
    - source: /srv/salt/virl/files/vsalt.py
    - source_hash: md5=28b7ad7b740b773a980fe646030585ed
    {% else %}
    - source: "salt://virl/files/vsalt.py"
    {% endif %}
  cmd.run:
    - name: /usr/local/bin/vsalt
    - require:
      - file: vsalt install and run
