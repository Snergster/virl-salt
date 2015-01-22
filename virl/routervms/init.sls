{% set onedev = salt['grains.get']('onedev', 'False') %}
{% set iosv = salt['pillar.get']('routervms:iosv', False ) %}
{% set iosvl2 = salt['pillar.get']('routervms:iosvl2', False ) %}
{% set iosxrv = salt['pillar.get']('routervms:iosxrv', False ) %}
{% set iosxrv432 = salt['pillar.get']('routervms:iosxrv432', False ) %}
{% set iosxrv52 = salt['pillar.get']('routervms:iosxrv52', False ) %}
{% set nxosv = salt['pillar.get']('routervms:nxosv', False) %}
{% set csr1000v = salt['pillar.get']('routervms:csr1000v', False) %}
{% set vpagent = salt['pillar.get']('routervms:vpagent', False) %}
{% set server = salt['pillar.get']('routervms:UbuntuServertrusty', True) %}
{% set iosvpref = salt['pillar.get']('virl:iosv', salt['grains.get']('iosv', True)) %}
{% set iosxrv432pref = salt['pillar.get']('virl:iosxrv432', salt['grains.get']('iosxrv432', True)) %}
{% set iosxrv52pref = salt['pillar.get']('virl:iosxrv52', salt['grains.get']('iosxrv52', True)) %}
{% set iosxrvpref = salt['pillar.get']('virl:iosxrv', salt['grains.get']('iosxrv', True)) %}
{% set csr1000vpref = salt['pillar.get']('virl:csr1000v', salt['grains.get']('csr1000v', True)) %}
{% set iosvl2pref = salt['pillar.get']('virl:iosvl2', salt['grains.get']('iosvl2', True)) %}
{% set nxosvpref = salt['pillar.get']('virl:nxosv', salt['grains.get']('nxosv', True)) %}
{% set vpagentpref = salt['pillar.get']('virl:vpagent', salt['grains.get']('vpagent', False)) %}
{% set serverpref = salt['pillar.get']('virl:server', salt['grains.get']('server', True)) %}

{% for each in 'iosv','iosxrv','iosv-l2','iosxrv52','iosxrv432','csr1000v','vpagent','nxosv','jumphost','UbuntuServertrusty' %}
{{each}}absent:
  file.absent:
    - name: /home/virl/images/{{each}}.pkg
{% endfor %}


iosv image:
{% if iosv and iosvpref %}
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
      - file: iosv image
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}

iosvl2 image:
{% if iosvl2 and iosvl2pref %}
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/iosvl2
  cmd.wait:
    - name: /usr/local/bin/add-images-auto iosv-l2.pkg
    - cwd: /home/virl/images
    - watch:
      - file: iosvl2 image
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}

iosxrv image:
{% if iosxrv and iosxrvpref %}
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
      - file: iosxrv image
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}

iosxrv432 image:
{% if iosxrv432 and iosxrv432pref %}
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/iosxrv432
  cmd.wait:
    - name: /usr/local/bin/add-images-auto iosxrv432.pkg
    - cwd: /home/virl/images
    - watch:
      - file: iosxrv432 image
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}

iosxrv52 image:
{% if iosxrv52 and iosxrv52pref %}
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/iosxrv52
  cmd.wait:
    - name: /usr/local/bin/add-images-auto iosxrv52.pkg
    - cwd: /home/virl/images
    - watch:
      - file: iosxrv52 image
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}

csr1000v image:
{% if csr1000v and csr1000vpref %}
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/csr1000v
  cmd.wait:
    - name: /usr/local/bin/add-images-auto csr1000v.pkg
    - cwd: /home/virl/images
    - watch:
      - file: csr1000v image
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}

vpagent image:
{% if vpagent and vpagentpref %}
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/vpagent
  cmd.wait:
    - name: /usr/local/bin/add-images-auto vpagent.pkg
    - cwd: /home/virl/images
    - watch:
      - file: vpagent image
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}

nxosv image:
{% if nxosv and nxosvpref %}
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/nxosv
  cmd.wait:
    - name: /usr/local/bin/add-images-auto nxosv.pkg
    - cwd: /home/virl/images
    - watch:
      - file: nxosv image
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}

jumphost image:
{% if salt['pillar.get']( 'routervms:jumphost' , 'False') == True %}
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/jumphost
  cmd.wait:
    - name: /usr/local/bin/add-servers jumphost.pkg
    - cwd: /home/virl/images
    - watch:
      - file: jumphost image
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}

UbuntuServertrusty image:
{% if server or serverpref %}
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/UbuntuServertrusty
  cmd.run:
    - name: /usr/local/bin/add-servers Ubuntu.Server.trusty.pkg
    - cwd: /home/virl/images
    - watch:
      - file: UbuntuServertrusty image
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}
