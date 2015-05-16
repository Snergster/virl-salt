
esxi ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.0.9.250.esxi.ova
    - name: /home/virl/virl.0.9.250.esxi.ova
    - source_hash: md5=b1594cc1a606fa21af37f7450e81f902
    - user: virl
    - group: virl
    - mode: 0755

delete esxi post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.0.9.250.esxi.ova
  - require:
    - file: esxi ova copy trial
