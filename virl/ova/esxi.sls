
esxi ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.1.0.26.esxi.ova
    - name: /home/virl/virl.1.0.26.esxi.ova
    - source_hash: md5=83db37298f9419ac12d25d8fb43a2f0c
    - user: virl
    - group: virl
    - mode: 0755

delete esxi post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.1.0.26.esxi.ova
  - require:
    - file: esxi ova copy trial
