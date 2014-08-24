{% set onedev = salt['grains.get']('onedev', 'False') %}
{% set domain = salt['grains.get']('append_domain', ' ') %}
{% set iosv = salt['pillar.get']('vmimages:iosv', 'False'  ) %}
{% set iosxrv = salt['pillar.get']('vmimages:iosxrv', 'False') %}

{% if iosv == 'True' %}
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
{%endif%}

{% if iosxrv == 'True' %}
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
{%endif%}
