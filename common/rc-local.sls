<<<<<<< HEAD
{% from "virl.jinja" import virl with context %}

{% if virl.cml %}

/etc/set-motd.sh:
  file.managed:
    - source: "salt://files/motd-cml.sh"
    - user: virl
    - group: virl
    - file_mode: 755

{% else %}

/etc/set-motd.sh:
  file.managed:
    - source: "salt://files/motd-virl.sh"
    - user: virl
    - group: virl
    - file_mode: 755

{% endif %}

add-rclocal-markers
=======
rclocal replace buckets:
>>>>>>> parent of 83b4f9c... Cleanup the rc.local blocks and add MOTDs for VIRL and CML.
  file.replace:
    - name: /etc/rc.local
    - pattern: '# By default this script does nothing.'
    - repl: |
          # VIRL use. Please dont replace or alter the blocks below
          # 001s Cinder
          # 001e end
          # 002s v6off
          # 002e end
          # 003s start
          # 003e end
          # 004s start
          # 004e end
          # 005s dummy
          # 005e end
          # 006s kvm
          # 006e end

rclocal v6off append:
  file.replace:
    - name: /etc/rc.local
    - pattern: '# 002s start'
    - repl: '# 002s v6off'

rclocal dummy append:
  file.replace:
    - name: /etc/rc.local
    - pattern: '# 005s start'
    - repl: '# 005s dummy'

rclocal kvm append:
  file.blockreplace:
    - name: /etc/rc.local
    - marker_start: "# 006s kvm"
    - marker_end: "# 006e"
    - content: |
             test -e /dev/kvm || touch /dev/kvm

{%if salt['pillar.get']('virl:dummy_int', salt['grains.get']('dummy_int', False )) %}

  {% if 'xenial' in salt['grains.get']('oscodename') %}
bridge rclocal:
  file.blockreplace:
    - name: /etc/rc.local
    - marker_start: "# 005s dummy"
    - marker_end: "# 005e"
    - content: |
             /sbin/ifup br1
             /sbin/ifup br2
             /sbin/ifup br3
             /sbin/ifup br4
             /sbin/ifup eth0
  {% else %}

dummy-rclocal:
  file.blockreplace:
    - name: /etc/rc.local
    - marker_start: "# 005s dummy"
    - marker_end: "# 005e"
    - content: |
             /sbin/ifup {{ salt['pillar.get']('virl:internalnet_port', salt['grains.get']('internalnet_port', 'eth4' )) }}
  {% endif %}

{% endif %}
