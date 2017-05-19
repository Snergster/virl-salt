{% from "virl.jinja" import virl with context %}

include:
  - .downdir

/var/www/download/linux:
{% if virl.vmm_linux %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - maxdepth: 0
    - dir_mode: 755
    - include_pat: '*zip'
    - exclude_pat: E@(.*exe$)|(.*dmg$)|(.*box$)
    - source: "salt://virl/vmm/{{ virl.venv }}/"
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*zip'
{% endif %}
