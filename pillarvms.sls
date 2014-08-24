{% set onedev = salt['grains.get']('onedev', 'False') %}
{% set domain = salt['grains.get']('append_domain', ' ') %}
{% for image in 'iosxrv','iosxrv511','nxosv','csr1000v','vpagent','iosv'}
  {% set {{image}}grain = salt['pillar.get']('vmimages:{{image}}', 'False') %}
{% endfor %}


{% for image in 'iosxrv','iosxrv511','nxosv','csr1000v','vpagent','iosv'}
{% if {{image}}grain == 'True' %}
/home/virl/images:
  file.recurse:
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/{{image}}
  cmd.wait:
    - name: /usr/local/bin/add-images-auto {{image}}.pkg
    - cwd: /home/virl/images
{%endif%}
{%endfor%}

# {% for image in 'iosv'}
# {% if {{image}}grain == 'True' %}
# /home/virl/images:
#   file.recurse:
#     - file_mode: 755
#     - dir_mode: 755
#     - user: virl
#     - group: virl
#     - source: salt://images/salt/{{image}}
#   cmd.wait:
#     - name: /usr/local/bin/add-images-auto {{image}}.pkg
#     - cwd: /home/virl/images
# {%endif%}
# {%endfor%}

