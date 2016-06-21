{% set hostname = salt['pillar.get']('virl:hostname', salt['grains.get']('hostname', 'virl')) %}

host remove local lan:
  host.absent:
    - name: {{ hostname }}.local.lan
    - ip:
      - ::1
      - 127.0.1.1
