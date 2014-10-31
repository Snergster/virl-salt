{% set onedev = salt['grains.get']('onedev', 'False') %}
{% set iosv = salt['pillar.get']('routervms:iosv', 'False'  ) %}
{% set iosxrv = salt['pillar.get']('routervms:iosxrv', 'False') %}
{% set iosvpref = salt['pillar.get']('virl:iosv', salt['grains.get']('iosv', True)) %}
{% set iosxrv432pref = salt['pillar.get']('virl:iosxrv432', salt['grains.get']('iosxrv432', True)) %}
{% set iosxrvpref = salt['pillar.get']('virl:iosxrv', salt['grains.get']('iosxrv', True)) %}
{% set csr1000vpref = salt['pillar.get']('virl:csr1000v', salt['grains.get']('csr1000v', True)) %}
{% set iosvl2pref = salt['pillar.get']('virl:iosvl2', salt['grains.get']('iosvl2', True)) %}
{% set nxosvpref = salt['pillar.get']('virl:nxosv', salt['grains.get']('nxosv', True)) %}
{% set vpagentpref = salt['pillar.get']('virl:vpagent', salt['grains.get']('vpagent', True)) %}
{% set serverpref = salt['pillar.get']('virl:server', salt['grains.get']('server', True)) %}

{% for each in 'iosv','iosxrv','iosxrv511','csr1000v','vpagent','nxosv','jumphost','UbuntuServertrusty' %}
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

iosxrv image:
{% if salt['pillar.get']( 'routervms:iosxrv' , 'False') == True %}
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

iosxrv511 image:
{% if salt['pillar.get']( 'routervms:iosxrv511' , 'False') == True %}
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
      - file: iosxrv511 image
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}

csr1000v image:
{% if salt['pillar.get']( 'routervms:csr1000v' , 'False') == True %}
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
{% if salt['pillar.get']( 'routervms:vpagent' , 'False') == True %}
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
{% if salt['pillar.get']( 'routervms:nxosv' , 'False') == True %}
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
{% if salt['pillar.get']( 'routervms:UbuntuServertrusty' , 'False') == True %}
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
