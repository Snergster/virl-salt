
pc ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.1.0.26.pc.ova
    - name: /home/virl/virl.1.0.26.pc.ova
    - source_hash: md5=071da48b95001dc83d32db657815578b
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.1.0.26.pc.ova
  - require:
    - file: pc ova copy trial
