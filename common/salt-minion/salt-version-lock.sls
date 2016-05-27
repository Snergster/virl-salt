/etc/apt/sources.list.d/saltstack.list:
  file.managed:
    - onlyif: 'test -e /etc/apt/sources.list.d/saltstack.list'
    - contents:  |
          deb https://repo.saltstack.com/apt/ubuntu/14.04/amd64/2015.8 trusty main

{% if '2016' in salt['grains.get']('saltversion') %}

2016 salt removal:
  pkg.removed:
    - pkgs:
      - salt-minion
      - salt-master
      - salt-common

2015 salt reintroduction:
  pkg.installed:
    - pkgs:
      - salt-minion
      - salt-master
      - salt-common

{% endif %}