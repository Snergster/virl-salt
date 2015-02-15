{% set onedev = salt['grains.get']('onedev', 'False') %}
{% set iosv = salt['pillar.get']('routervms:iosv', False ) %}
{% set iosvl2 = salt['pillar.get']('routervms:iosvl2', False ) %}
{% set iosxrv = salt['pillar.get']('routervms:iosxrv', False ) %}
{% set iosxrv432 = salt['pillar.get']('routervms:iosxrv432', False ) %}
{% set nxosv = salt['pillar.get']('routervms:nxosv', False) %}
{% set csr1000v = salt['pillar.get']('routervms:csr1000v', False) %}
{% set vpagent = salt['pillar.get']('routervms:vpagent', False) %}
{% set server = salt['pillar.get']('routervms:UbuntuServertrusty', True) %}

{% set iosvpref = salt['pillar.get']('virl:iosv', salt['grains.get']('iosv', True)) %}
{% set iosxrv432pref = salt['pillar.get']('virl:iosxrv432', salt['grains.get']('iosxrv432', True)) %}
{% set iosxrvpref = salt['pillar.get']('virl:iosxrv', salt['grains.get']('iosxrv', True)) %}
{% set csr1000vpref = salt['pillar.get']('virl:csr1000v', salt['grains.get']('csr1000v', True)) %}
{% set iosvl2pref = salt['pillar.get']('virl:iosvl2', salt['grains.get']('iosvl2', True)) %}
{% set nxosvpref = salt['pillar.get']('virl:nxosv', salt['grains.get']('nxosv', True)) %}
{% set vpagentpref = salt['pillar.get']('virl:vpagent', salt['grains.get']('vpagent', True)) %}
{% set serverpref = salt['pillar.get']('virl:server', salt['grains.get']('server', True)) %}


iosxrv432absent:
  file.absent:
    - name: /home/virl/images/iosxrv432.pkg

iosxrv432 image:
{% if iosxrv432 and iosxrv432pref %}
  file.recurse:
    - name: /home/virl/images
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    - source: salt://images/salt/iosxrv432
    - require:
      - file: iosxrv432absent
  cmd.wait:
    - name: /usr/local/bin/add-images-auto iosxrv432.pkg
    - cwd: /home/virl/images
    - watch:
      - file: iosxrv432 image
{% else %}
  file.exists:
    - name: /home/virl/images
{%endif%}
