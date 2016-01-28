{% set dummy_int = salt['pillar.get']('virl:dummy_int', salt['grains.get']('dummy_int', False )) %}

{% if dummy_int %}

dummy modprobe default:
  file.append:
    - name: /etc/modules
    - text: dummy numdummies=5
    - unless: grep dummy /etc/modules
  cmd.run:
    - name: modprobe dummy numdummies=5
    - unless: grep "^dummy" /proc/modules

{% else %}

remove dummy:
  file.line:
    - name: /etc/modules
    - content: 'dummy numdummies=5'
    - mode: delete

{% endif %}