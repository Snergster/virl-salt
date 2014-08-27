{% set ank = salt['grains.get']('ank', '19401') %}
{% set virltype = salt['grains.get']('virl type', 'stable') %}
{% set ramdisk = salt['grains.get']('ramdisk', 'True') %}
{% set httpproxy = salt['grains.get']('http proxy', 'https://proxy-wsa.esl.cisco.com:80') %}



/etc/fstab:
  file:
{% if ramdisk == 'True' %}
    - append:
    - text: 'ramdisk /var/lib/nova/instances tmpfs rw,relatime 0 0'
{% else %}
    - comment:
    - name: /etc/fstab
    - regex: ^ramdisk
{% endif %}
