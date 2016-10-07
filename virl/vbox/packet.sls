{% set adapter1ip = salt['network.interface_ip']('eth1') %}

adapter1 ghettoness:
  cmd.run:
    - names:
      - crudini --set /etc/virl/virl.cfg env virl_local_ip {{ adapter1ip }}
      - crudini --set /etc/virl/virl-core.ini env virl_local_ip {{ adapter1ip }}
      - crudini --set /etc/nova/nova.conf serial_console proxyclient_address {{ adapter1ip }}
      - crudini --set /etc/nova/nova.conf DEFAULT serial_port_proxyclient_address {{ adapter1ip }}

adapter1 restart:
  cmd.run:
    - order: last
    - names:
      - service nova-serialproxy restart
      - service virl-std restart
      - service virl-uwm restart
