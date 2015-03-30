upgrade host:
  pkg.uptodate:
    - refresh: True
    - kwargs:
      - dist_upgrade: False

apt cleanup:
  cmd.wait:
    - name: apt-get autoremove -y
    - onchanges:
      - pkg: upgrade host
