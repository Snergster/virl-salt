{% set ramdisk = salt['pillar.get']('ramdisk:mount', salt['grains.get']('ramdisk_mount', '/home/virl/foo')) %}

{{ ramdisk }}:
  file.directory:
    - makedirs: true
  mount.mounted:
    - device: ramdisk
    - fstype: tmpfs
    - opts: rw,relatime
    - dump: 0
    - pass_num: 0
    - require:
      - file: {{ ramdisk }}
