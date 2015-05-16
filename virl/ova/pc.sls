
pc ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.0.9.250.pc.ova
    - name: /home/virl/virl.0.9.250.pc.ova
    - source_hash: md5=b1594cc1a606fa21af37f7450e81f902
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.0.9.250.pc.ova
  - require:
    - file: pc ova copy trial
