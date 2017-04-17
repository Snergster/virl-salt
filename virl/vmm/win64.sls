{% from "virl.jinja" import virl with context %}

include:
  - .downdir

/var/www/download/win64:
{% if virl.vmm_win64 %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - maxdepth: 0
    - dir_mode: 755
    - include_pat: '*setup_64.exe'
    - exclude_pat:  E@(.*32.exe$)|(.*dmg$)|(.*zip$)|(.*box$)
    - source: "salt://virl/vmm/{{ virl.venv }}/"
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*64.exe'
{% endif %}
