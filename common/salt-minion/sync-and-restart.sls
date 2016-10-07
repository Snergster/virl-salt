drive sync all and restart :
  module.run:
  - name: saltutil.sync_all
  cmd.wait:
  - name: service salt-minion restart
  - watch:
    - module: drive sync all and restart

