
pc ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.1.0.0.pc.ova
    - name: /home/virl/virl.1.0.0.pc.ova
    - source_hash: md5=5e27b4ed9b49f973d81efae18f58d31b
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.1.0.0.pc.ova
  - require:
    - file: pc ova copy trial
