{% set dummy_int = salt['pillar.get']('virl:dummy_int', salt['grains.get']('dummy_int', True )) %}

{% if dummy_int %}

dummy modprobe default:
  file.append:
    - name: /etc/modules
    - text: dummy numdummies=5
  {% if not 'xenial' in salt['grains.get']('oscodename') %}
    - unless: grep dummy /etc/modules
  {% endif %}
  cmd.run:
    - name: modprobe dummy numdummies=5
    - unless: grep "^dummy" /proc/modules
}

  {% if 'xenial' in salt['grains.get']('oscodename') %}
hard up dummy interfaces:
  cmd.run:
    - names:
      - ip li add dummy0 type dummy
      - ip li add dummy1 type dummy
      - ip li add dummy2 type dummy
      - ip li add dummy3 type dummy
      - ip li add dummy4 type dummy
  {% endif %}

{% else %}

remove dummy:
  file.line:
    - name: /etc/modules
    - content: 'dummy numdummies=5'
    - mode: delete

{% endif %}