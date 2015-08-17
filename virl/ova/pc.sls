
pc ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.0.9.280.pc.ova
    - name: /home/virl/virl.0.9.280.pc.ova
    - source_hash: md5=9707730f6afc7cbcbe5393a2db5074b1
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.0.9.280.pc.ova
  - require:
    - file: pc ova copy trial
