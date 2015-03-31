upgrade host:
  module.run:
    - name: pkg.upgrade
    - refresh: True
    - dist_upgrade: False

apt cleanup:
  cmd.wait:
    - name: apt-get autoremove -y
    - onchanges:
      - pkg: upgrade host
