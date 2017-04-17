{% from "virl.jinja" import virl with context %}

include:
  - .downdir

/var/www/download/mac:
{% if virl.vmm_mac %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - maxdepth: 0
    - file_mode: 755
    - dir_mode: 755
    - include_pat: '*.dmg'
    - exclude_pat: E@(.*exe$)|(.*zip$)|(.*box$)
    - source: "salt://virl/vmm/{{ virl.venv }}/"
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*.dmg'
{% endif %}
