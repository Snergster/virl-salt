{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set vmm_mac = salt['pillar.get']('virl:vmm_mac', salt['grains.get']('vmm_mac', True)) %}
{% set vmm_win32 = salt['pillar.get']('virl:vmm_win32', salt['grains.get']('vmm_win32', True)) %}
{% set vmm_win64 = salt['pillar.get']('virl:vmm_win64', salt['grains.get']('vmm_win64', True)) %}
{% set vmm_linux = salt['pillar.get']('virl:vmm_linux', salt['grains.get']('vmm_linux', True)) %}


download:
  file.directory:
    - mode: 755
    - name: /var/www/download

{% if vmm_linux %}
/var/www/download/linux:
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - include_pat: *zip
    - exclude_pat: .virl*
    - source: "salt://vmm/{{ venv }}/"
    - require:
      - file: download
{% endif %}

{% if vmm_win64 %}
/var/www/download/win64:
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - include_pat: *setup_64.exe
    - exclude_pat: .virl*
    - source: "salt://vmm/{{ venv }}/"
    - require:
      - file: download
{% endif %}

{% if vmm_win32 %}
/var/www/download/win32:
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - include_pat: *setup_32.exe
    - exclude_pat: .virl*
    - source: "salt://vmm/{{ venv }}/"
    - require:
      - file: download
{% endif %}

{% if vmm_mac %}
/var/www/download/mac:
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - include_pat: *dmg
    - exclude_pat: .virl*
    - source: "salt://vmm/{{ venv }}/"
    - require:
      - file: download
{% endif %}
