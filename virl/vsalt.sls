vsalt install and run:
  file.managed:
    - mode: 755
    - name: /usr/local/bin/vsalt
    {% if masterless %}
    - source: /srv/salt/virl/files/vsalt.py
    - source_hash: md5=3abe32c562818fadb1cd068ea14ae07e
    {% else %}
    - source: "salt://virl/files/vsalt.py"
    {% endif %}
  cmd.run:
    - name: /usr/local/bin/vsalt
    - require:
      - file: vsalt install and run
      
