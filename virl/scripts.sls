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
  file.managed:
    - source: salt://virl/files/telnet_front
    - mode: 755

/etc/apparmor.d/local/telnet_front:
  file.managed:
    - source: salt://virl/files/telnet_front.aa
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
  file.managed:
    - source: salt://virl/files/kvm-intel.conf
    - mode: 755

/home/virl/.virl.jpg:
  file.managed:
    - source: salt://virl/files/virl.jpg
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
  file.managed:
    - source: salt://virl/files/failsafe.conf
    - mode: 644
