/etc/apt/sources.list.d/saltstack.list:
  file.managed:
    - onlyif: 'test -e /etc/apt/sources.list.d/saltstack.list'
    - contents:  |
          deb https://repo.saltstack.com/apt/ubuntu/14.04/amd64/2015.8 trusty main

