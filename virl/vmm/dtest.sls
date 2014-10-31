{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set vmm_mac = salt['pillar.get']('virl:vmm_mac', salt['grains.get']('vmm_mac', True)) %}
{% set vmm_win32 = salt['pillar.get']('virl:vmm_win32', salt['grains.get']('vmm_win32', True)) %}
{% set vmm_win64 = salt['pillar.get']('virl:vmm_win64', salt['grains.get']('vmm_win64', True)) %}
{% set vmm_linux = salt['pillar.get']('virl:vmm_linux', salt['grains.get']('vmm_linux', True)) %}


download:
  file.directory:
    - mode: 755
    - name: /var/www/download

{% for each in 'mac','setup_32','setup_64','zip' %}
/var/www/download:
  file.recurse:
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - include_pat: {{ each }}
    - exclude_pat: .virl*
    - source: "salt://vmm/{{ venv }}/"
    - require:
      - file: download

{% endfor %}
