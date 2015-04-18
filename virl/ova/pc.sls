
pc ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.0.9.238.pc.ova
    - name: /home/virl/virl.0.9.238.pc.ova
    - source_hash: md5=fcaf9a5a749b9761b84aa6754aff4385
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.0.9.238.pc.ova
  - require:
    - file: pc ova copy trial
