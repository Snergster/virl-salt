{% set controllerip = salt['pillar.get']('virl:internalnet_controller_IP',salt['grains.get']('internalnet_controller_IP', '172.16.10.250')) %}


mysql port check:
  openstack_config.present:
    - filename: /etc/mysql/my.cnf
    - section: 'mysqld'
    - parameter: 'bind-address'
    - value: '{{ controllerip }}'
