
pc ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.0.9.242.pc.ova
    - name: /home/virl/virl.0.9.242.pc.ova
    - source_hash: md5=070df0f19e8693bfc5f9ed97088fa069
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.0.9.242.pc.ova
  - require:
    - file: pc ova copy trial
