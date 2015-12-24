{% set ksm = salt['pillar.get']('virl:ksm', salt['grains.get']('ksm', false )) %}

{% if ksm %}
/etc/default/qemu-kvm:
  file.replace:
    - name: /etc/default/qemu-kvm
    - pattern: ^KSM_ENABLED=.*
    - repl: KSM_ENABLED=1
{% else %}
/etc/default/qemu-kvm:
  file.replace:
    - name: /etc/default/qemu-kvm
    - pattern: ^KSM_ENABLED=.*
    - repl: KSM_ENABLED=0
{% endif %}

qemu-kvm restart:
  service.running:
    - name: qemu-kvm
    - watch:
      - file: /etc/default/qemu-kvm


/usr/local/bin/ksmstat:
  file.managed:
    - source: salt://common/files/ksmstat.sh
    - mode: 0755