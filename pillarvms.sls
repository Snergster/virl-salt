{% set onedev = salt['grains.get']('onedev', 'False') %}
{% set domain = salt['grains.get']('append_domain', ' ') %}
{% set iosv = salt['pillar.get']('iosv', 'False'  ) %}
{% set iosxrv = salt['pillar.get']('iosxrv', 'False') %}


{% if salt['pillar.get']('iosv', 'False') %}
iosv:
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/iosv
  cmd.wait:
    - name: /usr/local/bin/add-images-auto iosv.pkg
    - cwd: /home/virl/images
    - watch:
      - file: iosv
{%endif%}


{% if salt['pillar.get']('iosxrv', 'False') %}
iosxrv:
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/iosxrv
  cmd.wait:
    - name: /usr/local/bin/add-images-auto iosxrv.pkg
    - cwd: /home/virl/images
    - watch:
      - file: iosv

{%endif%}

{% if salt['pillar.get']('iosxrv511', 'False') %}
iosxrv511:
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/iosxrv511
  cmd.wait:
    - name: /usr/local/bin/add-images-auto iosxrv511.pkg
    - cwd: /home/virl/images
    - watch:
      - file: iosv
{%endif%}


{% for each in 'csr1000v','vpagent','nxosv' %}
{{each}}:
{% if salt['pillar.get']( each , 'False') == False %}
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

