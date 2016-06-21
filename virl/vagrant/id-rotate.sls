
/etc/init.d/salt-id:
  file.managed:
    - source: 'salt://virl/files/salt-id.sh'
    - mode: 0755
  cmd.wait:
    - name: 'update-rc.d salt-id start 95 2 3 4 5 .'
    - watch:
      - file: /etc/init.d/salt-id
