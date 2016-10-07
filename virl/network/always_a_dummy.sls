
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
    - unless: 'ifconfig dummy4'
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
