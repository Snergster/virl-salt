{% from "virl.jinja" import virl with context %}

include:
  - .downdir

/var/www/download/win32:
{% if virl.vmm_win32 %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - maxdepth: 0
    - file_mode: 755
    - dir_mode: 755
    - include_pat: '*setup_32.exe'
    - exclude_pat: E@(.*64.exe$)|(.*dmg$)|(.*zip$)|(.*box$)
    - source: "salt://virl/vmm/{{ virl.venv }}/"
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*32.exe'
{% endif %}
