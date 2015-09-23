{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set ks_token = salt['pillar.get']('virl:keystone_service_token', salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh')) %}
{% set enable_horizon = salt['pillar.get']('virl:enable_horizon', salt['grains.get']('enable_horizon', True)) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}

{% if not masterless %}

/usr/local/bin/update-images:
  file.managed:
    - order: 1
    - source: salt://virl/files/update_images
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-images:
  file.managed:
    - order: 1
    - source: salt://virl/files/add-images
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-images-auto:
  file.managed:
    - order: 1
    - source: salt://virl/files/add-images-auto
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-servers:
  file.managed:
    - order: 1
    - source: salt://virl/files/add-servers
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/adduser_openstack:
  file.managed:
    - order: 1
    - source: salt://virl/files/adduser_openstack
    - user: virl
    - group: virl
    - mode: 755

{% else %}

/usr/local/bin/update-images:
  file.copy:
    - order: 1
    - force: true
    - source: /srv/salt/virl/files/update_images
    - onlyif: 'test -e /srv/salt/virl/files/update_images'
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-images:
  file.copy:
    - order: 1
    - force: true
    - source: /srv/salt/virl/files/add-images
    - onlyif: 'test -e /srv/salt/virl/files/add-images'
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-images-auto:
  file.copy:
    - order: 1
    - force: true
    - source: /srv/salt/virl/files/add-images-auto
    - onlyif: 'test -e /srv/salt/virl/files/add-images-auto'
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/add-servers:
  file.copy:
    - order: 1
    - force: true
    - source: /srv/salt/virl/files/add-servers
    - onlyif: 'test -e /srv/salt/virl/files/add-servers'
    - user: virl
    - group: virl
    - mode: 755

/usr/local/bin/adduser_openstack:
  file.copy:
    - order: 1
    - force: true
    - source: /srv/salt/virl/files/adduser_openstack
    - onlyif: 'test -e /srv/salt/virl/files/adduser_openstack'
    - user: virl
    - group: virl
    - mode: 755


{% endif %}

/opt/support/add-images:
  file.symlink:
    - target: /usr/local/bin/add-images
    - makedirs: true
    - mode: 0755

/opt/support/add-images-auto:
  file.symlink:
    - target: /usr/local/bin/add-images-auto
    - makedirs: true
    - mode: 0755

/opt/support/add-servers:
  file.symlink:
    - target: /usr/local/bin/add-servers
    - makedirs: true
    - mode: 0755

/etc/settings.ini:
  file.symlink:
    - target: /etc/virl.ini
    - makedirs: true
    - mode: 0755

/usr/bin/telnet_front:
  {% if not masterless %}
  file.managed:
    - source: salt://virl/files/telnet_front
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/telnet_front
    - force: true
  {% endif %}
    - mode: 755

/etc/apparmor.d/local/telnet_front:
  {% if not masterless %}
  file.managed:
    - source: salt://virl/files/telnet_front.aa
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/telnet_front.aa
    - force: true
  {% endif %}
    - mode: 644
  cmd.wait:
    - name: service apparmor reload
    - watch:
      - file: /etc/apparmor.d/local/telnet_front



{% if kilo %}

/etc/apparmor.d/libvirt/TEMPLATE.qemu:
  file.managed:
    - source: salt://virl/files/libvirt.template
    - makedirs: true
    - mode: 644
  cmd.wait:
    - name: service apparmor reload
    - watch:
      - file: /etc/apparmor.d/libvirt/TEMPLATE.qemu
{% else %}
/etc/apparmor.d/libvirt/TEMPLATE:
  {% if not masterless %}
  file.managed:
    - source: salt://virl/files/libvirt.template
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/libvirt.template
    - force: true
  {% endif %}
    - makedirs: true
    - mode: 644
  cmd.wait:
    - name: service apparmor reload
    - watch:
      - file: /etc/apparmor.d/libvirt/TEMPLATE
{% endif %}


/etc/modprobe.d/kvm-intel.conf:
  {% if not masterless %}
  file.managed:
    - source: salt://virl/files/kvm-intel.conf
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/kvm-intel.conf
    - force: true
  {% endif %}
    - mode: 755

/home/virl/.virl.jpg:
  {% if not masterless %}
  file.managed:
    - source: salt://virl/files/virl.jpg
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/virl.jpg
    - force: true
  {% endif %}
    - user: virl
    - group: virl

{% if not masterless %}
/etc/orig.virl.ini:
  file.managed:
    - source: salt://files/vsettings.ini
    - user: virl
    - group: virl
    - mode: 755
{% endif %}

/etc/init/failsafe.conf:
  {% if not masterless %}
  file.managed:
    - source: salt://virl/files/failsafe.conf
  {% else %}
  file.copy:
    - source: /srv/salt/virl/files/failsafe.conf
    - force: true
  {% endif %}
    - mode: 644
