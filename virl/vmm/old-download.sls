{% set cml = salt['grains.get']('cml', 'False') %}
{% set virl_type = salt['grains.get']('virl_type', 'stable') %}
{% set venv = salt['pillar.get']('behave:environment', 'stable') %}

include:
  - .downdir

/var/www/download:
  file.recurse:
    - order: 2
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - exclude_pat: .virl*
    - source: "salt://virl/vmm/{{ venv }}/"
    - require:
      - file: download
