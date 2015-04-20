include:
  - common.kvm

dist upgrade host:
  module.run:
    - name: pkg.upgrade
    - refresh: True
    - dist_upgrade: True

apt cleanup:
  cmd.wait:
    - name: apt-get autoremove -y
    - onchanges:
      - module: dist upgrade host
