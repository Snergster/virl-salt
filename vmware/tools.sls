
tar-vmware:
    file.absent:
      - name: /tmp/vmware-tools-distrib
    archive.extracted:
      - name: /tmp/
      - source: "salt://images/vmware/vmwaretools.tar.gz"
      - souce_hash: md5=a70a61d99dcaa38e55305164f75fdc14
      - archive_format: tar
      - if_missing: /tmp/vmware-tools/distrib/


install-vmware-tools:
    cmd.run:
        - cwd: /tmp/vmware-tools-distrib/
        - name: ./vmware-install.pl -d 2>&1

vmwaretools-absent:
  file:
    - absent
    - name: /tmp/vmwaretools.tar.gz
    - wait:
      - cmd: install-vmware-tools

vmwaretools dir remove:
  file:
    - absent
    - name: /tmp/vmware-tools-distrib
    - wait:
      - cmd: install-vmware-tools


