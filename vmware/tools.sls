/tmp/vmwaretools.tar.gz:
  file.managed:
    - source: "salt://images/vmware/vmwaretools.tar.gz"
    - order: 1

tar-vmware:
    module.run:
        - name: archive.tar
        - tarfile: /tmp/vmwaretools.tar.gz
        - order: 2
        - dest: /tmp
        - options: xf
        # FIXME: take out tar file name
        - cwd: /tmp/


install-vmware-tools:
    cmd.run:
        - order: 3
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


