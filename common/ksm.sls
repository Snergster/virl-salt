{% set ksm = salt['pillar.get']('virl:ksm', salt['grains.get']('ksm', true)) %}

{% if ksm %}
turn on ksm:
  file.replace:
    - name: /etc/default/qemu-kvm
    - pattern: ^KSM_ENABLED=.*
    - repl: KSM_ENABLED=1
{% else %}
turn off ksm:
  file.replace:
    - name: /etc/default/qemu-kvm
    - pattern: ^KSM_ENABLED=.*
    - repl: KSM_ENABLED=0
{% endif %}
/usr/local/bin/ksmstat:
  file.managed:
    - source: salt://common/files/ksmstat.sh
    - mode: 0755