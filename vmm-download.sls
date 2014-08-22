# download:
#   file.absent:
#     - order: 1
#     - user: virl
#     - group: virl
#     - name: /var/www/download

download2:
  file.directory:
    - order: 1
    - mode: 755
    - name: /var/www/download

/var/www/download:
  file.recurse:
    - order: 2
    - clean: true
    - file_mode: 755
    - dir_mode: 755
   {% if grains['virl type'] == 'stable' and grains['cml?'] == False %}
    - source: "salt://virl/files/vmm/stable/"
   {% elif grains['virl type'] == 'stable' and grains['cml?'] == True %}
    - source: "salt://virl/files/cml/stable/"
   {% elif grains['virl type'] == 'testing' and grains['cml?'] == False %}
    - source: "salt://virl/files/vmm/testing/"
   {% elif grains['virl type'] == 'testing' and grains['cml?'] == True %}
   - source: "salt://virl/files/cml/testing/"
   {% endif %}
