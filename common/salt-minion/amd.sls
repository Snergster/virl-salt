
{% if not 'xenial' in salt['grains.get']('oscodename') %}

fix for i386 evil:
  file.managed:
    - name: /etc/apt/sources.list.d/saltstack.list
    - unless: 'grep amd64 /etc/apt/sources.list.d/saltstack.list'
    - onlyif: 'test -e /etc/apt/sources.list.d/saltstack.list'
    - contents:  |
          deb https://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest trusty main

{% endif %}
