{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set vmm_mac = salt['pillar.get']('virl:vmm_mac', salt['grains.get']('vmm_mac', True)) %}
{% set vmm_win32 = salt['pillar.get']('virl:vmm_win32', salt['grains.get']('vmm_win32', True)) %}
{% set vmm_win64 = salt['pillar.get']('virl:vmm_win64', salt['grains.get']('vmm_win64', True)) %}
{% set vmm_linux = salt['pillar.get']('virl:vmm_linux', salt['grains.get']('vmm_linux', True)) %}

include:
  - .downdir

/var/www/download/mac:
{% if vmm_mac %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - include_pat: '*.dmg'
    - exclude_pat: E@(.*exe$)|(.*zip$)
    - source: "salt://vmm/{{ venv }}/"
    - require:
      - file: download
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/*.dmg'
{% endif %}
