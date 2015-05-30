/var/www/lab:
  file.recurse:
    - name: /var/www/lab
    - makedirs: True
    - source: "salt://labs"
    - clean: True
