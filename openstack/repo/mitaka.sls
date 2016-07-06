mitaka_base:
  cmd.run:
    - name: 'apt-add-repository cloud-archive:mitaka -y'
  module.run:
    - name: pkg.upgrade
    - refresh: True
    - dist_upgrade: False
    - require:
      - cmd: mitaka_base
