{% set mypassword = salt['pillar.get']('virl:mysql_password', salt['grains.get']('mysql_password', 'password')) %}

mysql port anycast:
  openstack_config.present:
    - filename: /etc/mysql/my.cnf
    - section: 'mysqld'
    - parameter: 'bind-address'
    - value: '0.0.0.0'
    - cmd.run:
      - name: service mysql restart
