
vextra install and run:
  file.managed:
    - mode: 2755
    - name: /usr/local/bin/vextra
    - source: "salt://virl/files/vextra.py"
  cmd.run:
    - name: /usr/local/bin/vextra
    - require:
      - file: vextra install and run

vsalt install and run:
  file.managed:
    - mode: 2755
    - name: /usr/local/bin/vsalt
    - source: "salt://virl/files/vsalt"
