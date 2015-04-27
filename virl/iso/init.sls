
iso copy trial:
  file.managed:
    - source: salt://images/iso/virl.0.9.242.iso
    - name: /home/virl/virl.0.9.242.iso
    - source_hash: md5=5bf49eccdb1a42a020a1e06fa3b3bfe1
    - user: virl
    - group: virl
    - mode: 0755

delete post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/iso/virl.0.9.242.iso
  - require:
    - file: iso copy trial
