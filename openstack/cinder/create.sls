{% set cinder_file = salt['pillar.get']('virl:cinder_file', salt['grains.get']('cinder_file', False )) %}
{% set cinder_device = salt['pillar.get']('virl:cinder_device', salt['grains.get']('cinder_device', False )) %}
{% set cinder_size = salt['pillar.get']('virl:cinder_size', salt['grains.get']('cinder_size', 2000 )) %}
{% set cinder_location = salt['pillar.get']('virl:cinder_location', salt['grains.get']('cinder_location', '/var/lib/cinder/cinder-volumes.lvm' )) %}



{% if cinder_file %}
  {% if not cinder_size == 2000 %}
delete old cinder file:
  cmd.run:
    - name: /sbin/vgremove cinder-volumes /dev/loop0
  file.absent:
    - name: {{ cinder_location }}
  {% endif %}

create cinder file:
  cmd.run:
    - onlyif: test ! -e {{ cinder_location }}
    - name:  |
        /bin/dd if=/dev/zero of={{ cinder_location }} bs=1M count={{cinder_size}}
        /sbin/losetup -f --show {{ cinder_location }}
        /sbin/pvcreate /dev/loop0
        /sbin/vgcreate cinder-volumes /dev/loop0

{% elif cinder_device %}
create cinder device:
  cmd.run:
    - name:  |
        /sbin/pvcreate {{ cinder_location }}
        /sbin/vgcreate cinder-volumes {{ cinder_location }}
{% endif %}

{% if cinder_file or cinder_device %}

cinder-rclocal:
  file.replace:
    - name: /etc/rc.local
    - pattern: '# By default this script does nothing.'
    - repl: /sbin/losetup -f {{ cinder_location }}

{% endif %}
