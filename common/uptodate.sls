upgrade host:
  pkg.uptodate:
    - refresh: True

apt cleanup:
  cmd.wait:
    - name: apt-get autoremove -y
    - onchanges:
      - pkg: upgrade host
