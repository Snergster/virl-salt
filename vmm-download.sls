{% set cml = salt['grains.get']('cml', 'False') %}
{% set virl_type = salt['grains.get']('virl_type', 'stable') %}

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
   {% if virl type == 'stable' and cml == False %}
    - source: "salt://vmm/stable/"
   {% elif virl type == 'stable' and cml == True %}
    - source: "salt://cml/stable/"
   {% elif virl type == 'testing' and cml == False %}
    - source: "salt://vmm/qa/"
   {% elif virl type == 'testing' and cml == True %}
    - source: "salt://cml/qa/"
   {% endif %}
    - require:
      - file: download2

