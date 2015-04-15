
pc ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.0.9.236.pc.ova
    - name: /home/virl/virl.0.9.236.pc.ova
    - source_hash: md5=25030f7102baba8874c68b23673cfc60
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.0.9.236.pc.ova
  - require:
    - file: pc ova copy trial
