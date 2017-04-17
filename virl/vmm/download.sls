{% from "virl.jinja" import virl with context %}

include:
  - .downdir

/var/www/download/linux:
{% if virl.vmm_linux %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - maxdepth: 0
    - include_pat: '*zip'
    - exclude_pat: E@(.*exe$)|(.*dmg$)
    {% if virl.cml %}
    - source: "salt://cml/vmm/{{ virl.venv }}/"
    {% else %}
    - source: "salt://virl/vmm/{{ virl.venv }}/"
    {% endif %}
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*zip'
{% endif %}


/var/www/download/win64:
{% if virl.vmm_win64 %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - maxdepth: 0
    - include_pat: '*setup_64.exe'
    - exclude_pat:  E@(.*32.exe$)|(.*dmg$)|(.*zip$)
    {% if virl.cml %}
    - source: "salt://cml/vmm/{{ virl.venv }}/"
    {% else %}
    - source: "salt://virl/vmm/{{ virl.venv }}/"
    {% endif %}
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*64.exe'
{% endif %}


/var/www/download/win32:
{% if virl.vmm_win32 %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - maxdepth: 0
    - dir_mode: 755
    - include_pat: '*setup_32.exe'
    - exclude_pat: E@(.*64.exe$)|(.*dmg$)|(.*zip$)
    {% if virl.cml %}
    - source: "salt://cml/vmm/{{ virl.venv }}/"
    {% else %}
    - source: "salt://virl/vmm/{{ virl.venv }}/"
    {% endif %}
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*32.exe'
{% endif %}


/var/www/download/mac:
{% if virl.vmm_mac %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - maxdepth: 0
    - include_pat: '*.dmg'
    - exclude_pat: E@(.*exe$)|(.*zip$)
    {% if virl.cml %}
    - source: "salt://cml/vmm/{{ virl.venv }}/"
    {% else %}
    - source: "salt://virl/vmm/{{ virl.venv }}/"
    {% endif %}
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*.dmg'
{% endif %}
