vinstall install and run:
  file.managed:
    - mode: 0755
    - name: /usr/local/bin/vinstall
    - source: "salt://virl/files/vinstall.py"
  cmd.run:
    - name: /usr/local/bin/vinstall salt
    - require:
      - file: vinstall install and run

