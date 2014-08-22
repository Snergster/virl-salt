/var/www/training:
  file.recurse:
    - file_mode: 755
    - dir_mode: 755
    - makedirs: True
    - source: "salt://virl/files/training"
  cmd.wait:
    - name: service apache2 restart
    - watch:
      - file: /var/www/training

/var/www/doc:
  file.recurse:
    - file_mode: 755
    - dir_mode: 755
    - makedirs: True
    - source: "salt://virl/files/virl.standalone/glocal/std/virl-cli/doc/build/html"
  cmd.wait:
    - name: service apache2 restart
    - watch:
      - file: /var/www/doc

