{% if 'xenial' in salt['grains.get']('oscodename') %}
/etc/apt/sources.list.d/virl-trusty.list:
  file.managed:
    - mode: 0644
    - contents:  |
          deb http://us.archive.ubuntu.com/ubuntu/ trusty main restricted universe
          deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates main restricted universe

{% endif %}