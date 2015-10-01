sync modules:
  module.run:
    - name: network.interface 
    - iface: {{salt['pillar.get']('virl:public_port', salt['grains.get']('public_port', 'eth0'))}}
