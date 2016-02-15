
esxi compute ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.compute.1.0.26.esxi.ova
    - name: /home/virl/virl.compute.1.0.26.esxi.ova
    - source_hash: md5=5e75ef3bfb602536e6ffe576bc844d2c
    - user: virl
    - group: virl
    - mode: 0755

delete compute esxi post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.compute.1.0.26.esxi.ova
  - require:
    - file: esxi compute ova copy trial
