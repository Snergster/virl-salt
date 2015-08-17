
esxi ova copy trial:
  file.managed:
    - source: salt://images/ova/virl.0.9.280.esxi.ova
    - name: /home/virl/virl.0.9.280.esxi.ova
    - source_hash: md5=d3c6018711719a66968576b07f975bae
    - user: virl
    - group: virl
    - mode: 0755

delete esxi post copy:
  file.absent:
  - name: /var/cache/salt/minion/files/base/images/ova/virl.0.9.280.esxi.ova
  - require:
    - file: esxi ova copy trial
