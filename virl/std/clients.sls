
{% from "virl.jinja" import virl with context %}

virl_client download:
{% if virl.std_clients %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - maxdepth: 0
    - dir_mode: 755
    - include_pat: 'VIRL_CLIENTS*.whl'
    - exclude_pat:  E@(.*64.exe)|(.*32.exe$)|(.*dmg$)|(.*zip$)|(.*box$)
    - source: "salt://std/{{ virl.venv }}/"
{% else %}
  module.run:
    - name: file.find
    - path: /var/www/download/
    - kwargs:
        name: VIRL_CLIENTS*.whl
        delete: 'f'
        maxdepth: 0
{% endif %}
