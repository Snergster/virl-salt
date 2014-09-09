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
   {% if virl type == 'testing' %}
    - source: "salt://vmm/qa/"
   {% else %}
    - source: "salt://vmm/stable/"
   {% endif %}
    - require:
      - file: download2

