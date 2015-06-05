/srv/salt2/images/private:
  file.recurse:
    - source: 'salt://images/private'
    - clean: True
    - user: virl
    - makedirs: True
    - group: virl
    - file_mode: 755
    - include_empty: True

