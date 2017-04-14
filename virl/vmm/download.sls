{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set vmm_mac = salt['pillar.get']('virl:vmm_mac', salt['grains.get']('vmm_mac', True)) %}
{% set vmm_win32 = salt['pillar.get']('virl:vmm_win32', salt['grains.get']('vmm_win32', True)) %}
{% set vmm_win64 = salt['pillar.get']('virl:vmm_win64', salt['grains.get']('vmm_win64', True)) %}
{% set vmm_linux = salt['pillar.get']('virl:vmm_linux', salt['grains.get']('vmm_linux', True)) %}
{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}

include:
  - .downdir

/var/www/download/linux:
{% if vmm_linux %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - maxdepth: 0
    - include_pat: '*zip'
    - exclude_pat: E@(.*exe$)|(.*dmg$)
    {% if cml %}
    - source: "salt://cml/vmm/{{ venv }}/"
    {% else %}
    - source: "salt://virl/vmm/{{ venv }}/"
    {% endif %}
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*zip'
{% endif %}


/var/www/download/win64:
{% if vmm_win64 %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - maxdepth: 0
    - include_pat: '*setup_64.exe'
    - exclude_pat:  E@(.*32.exe$)|(.*dmg$)|(.*zip$)
    {% if cml %}
    - source: "salt://cml/vmm/{{ venv }}/"
    {% else %}
    - source: "salt://virl/vmm/{{ venv }}/"
    {% endif %}
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*64.exe'
{% endif %}


/var/www/download/win32:
{% if vmm_win32 %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - maxdepth: 0
    - dir_mode: 755
    - include_pat: '*setup_32.exe'
    - exclude_pat: E@(.*64.exe$)|(.*dmg$)|(.*zip$)
    {% if cml %}
    - source: "salt://cml/vmm/{{ venv }}/"
    {% else %}
    - source: "salt://virl/vmm/{{ venv }}/"
    {% endif %}
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*32.exe'
{% endif %}


/var/www/download/mac:
{% if vmm_mac %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - maxdepth: 0
    - include_pat: '*.dmg'
    - exclude_pat: E@(.*exe$)|(.*zip$)
    {% if cml %}
    - source: "salt://cml/vmm/{{ venv }}/"
    {% else %}
    - source: "salt://virl/vmm/{{ venv }}/"
    {% endif %}
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*.dmg'
{% endif %}
