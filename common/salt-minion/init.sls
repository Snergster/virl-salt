include:
  - common.salt-minion.virtwhat
  - common.salt-minion.dateutil
  - common.salt-minion.pyinotify
  - common.salt-master.pygit2
  - common.salt-master.psutil
  - common.salt-minion.glance
{% if not 'xenial' in salt['grains.get']('oscodename') %}
  - common.salt-minion.boto
  - common.salt-minion.mako
  - common.salt-minion.msgpack-pure
  - common.salt-minion.msgpack-python
{% endif %}