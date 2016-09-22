{% set dummy_int = salt['pillar.get']('virl:dummy_int', salt['grains.get']('dummy_int', True )) %}

{% if dummy_int %}

  {% if 'xenial' in salt['grains.get']('oscodename') %}

dummy modprobe default:
  file.append:
    - name: /etc/modules
    - text: dummy 
    - unless: grep dummy /etc/modules

/etc/modprobe.d/dummy.conf:
  file.managed:
    - makedirs: True
    - contents: |
         options dummy numdummies=5

hard up dummy interfaces:
  cmd.run:
    - names:
      - modprobe dummy numdummies=5
      - ip li add dummy0 type dummy
      - ip li add dummy1 type dummy
      - ip li add dummy2 type dummy
      - ip li add dummy3 type dummy
      - ip li add dummy4 type dummy

  {% else %}

dummy modprobe default:
  file.append:
    - name: /etc/modules
    - text: dummy numdummies=5
    - unless: grep dummy /etc/modules
  cmd.run:
    - name: modprobe dummy numdummies=5
    - unless: grep "^dummy" /proc/modules

  {% endif %}

{% else %}

  {% if 'xenial' in salt['grains.get']('oscodename') %}

remove dummy.conf:
  file.remove:
    - name: /etc/modprobe.d/dummy.conf

remove dummy from modules:
  file.line:
    - name: /etc/modules
    - content: 'dummy'
    - mode: delete

  {% else %}

remove dummy:
  file.line:
    - name: /etc/modules
    - content: 'dummy numdummies=5'
    - mode: delete

  {% endif %}


{% endif %}