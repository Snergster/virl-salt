sync opt foobar:
  rsync.synchronized:
    - source: salt://std/stable
    - name: /tmp/foobar
