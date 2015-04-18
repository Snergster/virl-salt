
iso copy trial:
  file.managed:
    - source: salt://images/iso/virl.0.9.238.iso
    - name: /home/virl/virl.0.9.238.iso
    - source_hash: md5=19b9f44cd33b85d3c73307c10133fd8d
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/iso/virl.0.9.238.iso
  - require:
    - file: iso copy trial
