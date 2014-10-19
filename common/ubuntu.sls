qemu hold:
  apt.held:
    - name: qemu-kvm

linuxbridge hold:
  apt.held:
    - name: neutron-plugin-linuxbridge-agent
    - onlyif: 'test -e /usr/bin/neutron-linuxbridge-agent'

salt minion hold:
  apt.held:
    - name: salt-minion

upgrade mess:
  pkg.uptodate:
    - refresh: True
