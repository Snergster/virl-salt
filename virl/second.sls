vinstall second:
  cmd.run:
    - name: /usr/local/bin/vinstall second

vinstall third:
  cmd.run:
    - name: /usr/local/bin/vinstall third
    - require:
      - cmd: vinstall second

post third sync:
  cmd.run:
    - name: salt-call saltutil.sync_all
    - require:
      - cmd: vinstall second
      
vinstall fourth:
  cmd.run:
    - name: /usr/local/bin/vinstall fourth
    - require:
      - cmd: vinstall third
