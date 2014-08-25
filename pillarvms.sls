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
{%endif%}

{% if salt['pillar.get']('nxosv', 'False') %}
nxosv:
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
{%endif%}

{% if salt['pillar.get']('csr1000v', 'False') %}
csr1000v:
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
{%endif%}

{% if salt['pillar.get']('vpagent', 'False') %}
vpagent:
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
{%endif%}
