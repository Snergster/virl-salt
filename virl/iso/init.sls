
iso copy trial:
  file.managed:
    - source: salt://images/iso/virl.1.0.0.iso
    - name: /home/virl/virl.1.0.0.iso
    - source_hash: md5=ae98591219058fcaf2aafe53d5164432
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/iso/virl.1.0.0.iso
  - require:
    - file: iso copy trial
