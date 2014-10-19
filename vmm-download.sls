{% set cml = salt['grains.get']('cml', 'False') %}
{% set virl_type = salt['grains.get']('virl_type', 'stable') %}
{% set venv = salt['pillar.get']('behave:environment', 'stable') %}

download:
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
    - exclude_pat: .virl*
    - source: "salt://vmm/{{ venv }}/"
    - require:
      - file: download

