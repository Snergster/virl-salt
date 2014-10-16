qemu hold:
  apt.held:
    - name: qemu-kvm

linuxbridge hold:
  apt.held:
    - name: neutron-plugin-linuxbridge-agent

salt master hold:
  apt.held:
    - name: salt-master

salt minion hold:
  apt.held:
    - name: salt-minion

salt common hold:
  apt.held:
    - name: salt-common

upgrade mess:
  pkg.upgrade:
    - refresh: True
