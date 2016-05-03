/srv/salt2/images/salt:
  file.recurse:
    - source: 'salt://images/salt'
    - clean: True
    - user: virl
    - makedirs: True
    - group: virl
    - file_mode: 755
    - include_empty: True

image cache cleaner:
  file.directory:
    - name: /var/cache/salt/minion/files/base/images/salt
    - clean: True
    - onchanges:
      - file: /srv/salt2/images/salt

/srv/salt2/images/bridge:
  file.recurse:
    - source: 'salt://images/bridge'
    - clean: True
    - user: virl
    - makedirs: True
    - group: virl
    - file_mode: 755
    - include_empty: True

/srv/salt2/images/vmware:
  file.recurse:
    - source: 'salt://images/vmware'
    - clean: True
    - user: virl
    - makedirs: True
    - group: virl
    - file_mode: 755
    - include_empty: True

/srv/salt2/images/misc:
  file.recurse:
    - source: 'salt://images/misc'
    - clean: True
    - user: virl
    - makedirs: True
    - group: virl
    - file_mode: 755
    - include_empty: True
