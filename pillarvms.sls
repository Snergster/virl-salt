{% set onedev = salt['grains.get']('onedev', 'False') %}
{% set domain = salt['grains.get']('append_domain', ' ') %}
{% set iosv = salt['pillar.get']('iosv', 'False'  ) %}
{% set iosxrv = salt['pillar.get']('iosxrv', 'False') %}


{% for each in 'iosv','iosxrv','iosxrv511','csr1000v','vpagent','nxosv' %}
{{each}}:
{% if salt['pillar.get']( each , 'False') == True %}
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/{{each}}
  cmd.wait:
    - name: /usr/local/bin/add-images-auto {{each}}.pkg
    - cwd: /home/virl/images
    - watch:
      - file: {{each}}
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}
{% endfor %}

