sync modules:
  module.run:
    - name: saltutil.sync_modules
    - onlyif: test ! -e /var/cache/salt/minion/extmods/modules/virl_core.py

sync states:
  module.run:
    - name: saltutil.sync_states
    - onlyif: test ! -e /var/cache/salt/minion/extmods/states/virl_core.py
