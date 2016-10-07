{% from "virl.jinja" import virl with context %}

verify apparmor:
  pkg.installed:
    - name: apparmor
    - refresh: false

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
    - require:
      - pkg: verify apparmor
  cmd.wait:
    - name: service apparmor reload
    - watch:
      - file: /etc/apparmor.d/local/telnet_front




/etc/apparmor.d/libvirt/TEMPLATE.qemu:
  file.managed:
    - source: salt://virl/files/libvirt.template
    - makedirs: true
    - mode: 644
    - require:
      - pkg: verify apparmor
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

{% if not virl.masterless %}
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
