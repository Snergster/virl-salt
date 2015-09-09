
pc ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.0.9.293.pc.ova
    - name: /home/virl/virl.0.9.293.pc.ova
    - source_hash: md5=e4644cb55bb1109aa707469cf52c84c3
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.0.9.293.pc.ova
  - require:
    - file: pc ova copy trial
