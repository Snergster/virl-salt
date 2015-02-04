{% set uwmport = salt['pillar.get']('virl:virl_user_management', salt['grains.get']('virl_user_management', '19400')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}

{% if cml %}
/srv/salt/virl/files/cmlweb.tar:
  file.managed:
    - source: 'salt://virl/files/cmlweb.tar'
    - mode: 755
    - user: virl
    - group: virl

apache overwrite:
  archive:
    - extracted
    - name: /var/www/html
    - source: file:///srv/salt/virl/files/cmlweb.tar
    - source_hash: md5=d67f85b69bc80bb1ac4e2592d20a4c83
    - archive_format: tar
    - onchanges:
      - file: apache dir remove

apache dir remove:
  file.absent:
    - name: /var/www/html
    - onchanges:
      - file: /srv/salt/virl/files/cmlweb.tar

{% else %}

/srv/salt/virl/files/virlweb.tar:
  file.managed:
    - source: 'salt://virl/files/virlweb.tar'
    - mode: 755
    - user: virl
    - group: virl

apache overwrite:
  archive:
    - extracted
    - name: /var/www/html
    - source: file:///srv/salt/virl/files/virlweb.tar
    - source_hash: md5=b1a24317d5937caeba82fbc049f5055f
    - archive_format: tar
    - onchanges:
      - file: apache dir remove


apache dir remove:
  file.absent:
    - name: /var/www/html
    - onchanges:
      - file: /srv/salt/virl/files/virlweb.tar
{% endif %}

uwm port replace:
  file.replace:
    - order: last
    - name: /var/www/html/index.html
    - pattern: :\d{2,}"
    - repl: :{{ uwmport }}"
    - unless: grep {{ uwmport }} /var/www/html/index.html
