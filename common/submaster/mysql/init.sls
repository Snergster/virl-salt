/etc/salt/master.d/mysql.conf:
  file.managed:
    - makedirs: True
    - contents_pillar: mysql:config
