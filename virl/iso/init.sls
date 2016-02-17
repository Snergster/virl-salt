
iso copy trial:
  file.managed:
    - source: salt://images/iso/virl.1.0.26.iso
    - name: /home/virl/virl.1.0.26.iso
    - source_hash: md5=1a4f7052e88493bb023e2aaa48d03944
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/iso/virl.1.0.26.iso
  - require:
    - file: iso copy trial
