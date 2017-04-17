{% from "virl.jinja" import virl with context %}

include:
  - .downdir

/var/www/download:
  file.recurse:
    - order: 2
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - exclude_pat: .virl*
    - source: "salt://virl/vmm/{{ virl.venv }}/"
    - require:
      - file: download
