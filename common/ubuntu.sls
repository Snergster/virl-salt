qemu hold:
  pkg.hold:
    - name: qemu-kvm

linuxbridge hold:
  pkg.hold:
    - name: neutron-plugin-linuxbridge-agent

salt master hold:
  pkg.hold:
    - name: salt-master

salt minion hold:
  pkg.hold:
    - name: salt-minion

salt common hold:
  pkg.hold:
    - name: salt-common

upgrade mess:
  pkg.upgrade
