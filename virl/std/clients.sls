{% set venv = salt['pillar.get']('behave:environment', 'stable') %}
{% set std_clients = salt['pillar.get']('virl:std_clients', salt['grains.get']('std_clients', True)) %}

virl_client download:
{% if std_clients %}
  file.recurse:
    - name: /var/www/download
    - clean: true
    - file_mode: 755
    - maxdepth: 0
    - dir_mode: 755
    - include_pat: 'VIRL_CLIENTS*.whl'
    - exclude_pat:  E@(.*64.exe)|(.*32.exe$)|(.*dmg$)|(.*zip$)|(.*box$)
    - source: "salt://std/{{ venv }}/"
{% else %}
  cmd.run:
    - name: 'rm -f /var/www/download/VIRL_CLIENTS*.whl'
{% endif %}
