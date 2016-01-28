{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}
{% set ks_token = salt['pillar.get']('virl:keystone_service_token', salt['grains.get']('keystone_service_token', 'fkgjhsdflkjh')) %}
{% set enable_horizon = salt['pillar.get']('virl:enable_horizon', salt['grains.get']('enable_horizon', True)) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', true)) %}


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




/etc/apparmor.d/libvirt/TEMPLATE.qemu:
  file.managed:
    - source: salt://virl/files/libvirt.template
    - makedirs: true
    - mode: 644
  cmd.wait:
    - name: service apparmor reload
    - watch:
      - file: /etc/apparmor.d/libvirt/TEMPLATE.qemu


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
    - source: salt://virl/files/vsettings.ini
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
