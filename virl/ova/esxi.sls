
esxi ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.1.0.11.esxi.ova
    - name: /home/virl/virl.1.0.11.esxi.ova
    - source_hash: md5=f2970dd1497043543398b6c717067926
    - user: virl
    - group: virl
    - mode: 0755

delete esxi post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.1.0.11.esxi.ova
  - require:
    - file: esxi ova copy trial
