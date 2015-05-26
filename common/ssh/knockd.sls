iptables-persistent:
  pkg.installed

knockd:
  pkg.installed

/etc/knockd.conf:
  file.managed:
    - contents_pillar: common:knockd:conf

/etc/default/knockd:
  file.replace:
    - pattern: START_KNOCKD=0
    - repl: START_KNOCKD=1
    - require:
      - pkg: knockd
      - file: /etc/knockd.conf
  cmd.wait:
    - name: service knockd restart
    - watch:
      - file: /etc/default/knockd

/etc/iptables/rules.v4:
  file.managed:
    - source: 'salt://submaster/rules.v4'
  cmd.run:
    - name: 'service iptables-persistent start'
    - require:
      - pkg: iptables-persistent
      - cmd: /etc/default/knockd.conf
