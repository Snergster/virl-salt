/etc/apt/sources.list.d/saltstack.list:
  file.managed:
    - onlyif: 'test -e /etc/apt/sources.list.d/saltstack.list'
    - contents:  |
          deb https://repo.saltstack.com/apt/ubuntu/14.04/amd64/2015.8 trusty main

{% if '2016' in salt['grains.get']('saltversion') %}

kill master 2016 first:
  service.dead:
    - name: salt-master

kill minion 2016 first:
  service.dead:
    - name: salt-minion

2015 salt reintroduction:
  pkg.installed:
    - refresh: true
    - pkgs:
      - salt-minion: '2015.8.10+ds-1'
      - salt-master: '2015.8.10+ds-1'
      - salt-common: '2015.8.10+ds-1'

2015 salt minion running:
  service.running:
    - name: salt-minion
    - watch:
      - pkg: 2015 salt reintroduction

{% endif %}