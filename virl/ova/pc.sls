
pc ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.1.0.11.pc.ova
    - name: /home/virl/virl.1.0.11.pc.ova
    - source_hash: md5=da5da51c36a1549aa176ab077faff6bc
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.1.0.11.pc.ova
  - require:
    - file: pc ova copy trial
