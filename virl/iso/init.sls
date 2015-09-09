
iso copy trial:
  file.managed:
    - source: salt://images/iso/virl.0.9.293.iso
    - name: /home/virl/virl.0.9.293.iso
    - source_hash: md5=2f7dd5d9a2c7e75ed2a01efb79dac7b5
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/iso/virl.0.9.293.iso
  - require:
    - file: iso copy trial
