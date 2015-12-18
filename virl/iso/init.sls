
iso copy trial:
  file.managed:
    - source: salt://images/iso/virl.1.0.11.iso
    - name: /home/virl/virl.1.0.11.iso
    - source_hash: md5=a59084afc03ee5090c4b533caaaa41c2
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/iso/virl.1.0.11.iso
  - require:
    - file: iso copy trial
