
esxi ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.0.9.242.esxi.ova
    - name: /home/virl/virl.0.9.242.esxi.ova
    - source_hash: md5=2d90595d63ed664c1204921426a1d6e6
    - user: virl
    - group: virl
    - mode: 0755

delete esxi post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.0.9.242.esxi.ova
  - require:
    - file: esxi ova copy trial
