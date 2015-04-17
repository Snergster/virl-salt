{% set cinder_file = salt['pillar.get']('virl:cinder_file', salt['grains.get']('cinder_file', False )) %}
{% set cinder_device = salt['pillar.get']('virl:cinder_device', salt['grains.get']('cinder_device', False )) %}
{% set cinder_size = salt['pillar.get']('virl:cinder_size', salt['grains.get']('cinder_size', 20000 )) %}
{% set cinder_safe = salt['pillar.get']('virl:cinder_safe', salt['grains.get']('cinder_safe', False )) %}
{% set cinder_location = salt['pillar.get']('virl:cinder_location', salt['grains.get']('cinder_location', '/var/lib/cinder/cinder-volumes.lvm' )) %}



{% if cinder_file %}
  {% if not cinder_safe %}
delete dead cinder file:
  cmd.run:
    - name: |
        /usr/sbin/service cinder-volume stop
        /sbin/vgremove cinder-volumes
        /sbin/losetup -d /dev/loop0
    - onlyif: test -e {{ cinder_location }}
  file.absent:
    - name: {{ cinder_location }}
    - onlyif: test -e {{ cinder_location }}

cinder-volume dead:
  service.disabled:
    - name: cinder-volume

cinder-scheduler dead:
  service.disabled:
    - name: cinder-scheduler

cinder-api dead:
  service.disabled:
    - name: cinder-api
  {% endif %}
{% endif %}
