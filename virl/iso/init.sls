
iso copy trial:
  file.managed:
    - source: salt://images/iso/virl.0.9.250.iso
    - name: /home/virl/virl.0.9.250.iso
    - source_hash: md5=ade824871dd7c955c18345f1cbb4ac3a
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/iso/virl.0.9.250.iso
  - require:
    - file: iso copy trial
