{% set uwmport = salt['pillar.get']('virl:virl_user_management', salt['grains.get']('virl_user_management', '19400')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

{% if not masterless %}
apache overwrite:
  file.recurse:
    - name: /var/www/html
    - source: salt://files/virlweb
    - user: root
    - group: root
    - file_mode: 755

{% else %}
apache tar overwrite:
  archive:
    - extracted
    - name: /var/www/html
    - source: file:///srv/salt/virl/files/virlweb.tar
    - source_hash: md5=b1a24317d5937caeba82fbc049f5055f
    - onlyif: 'test -e /srv/salt/virl/files/virlweb.tar'
    - archive_format: tar
    - require:
      - file: apache dir remove

apache dir remove:
  file.absent:
    - name: /var/www/html
    - onlyif: 'test -e /srv/salt/virl/files/virlweb.tar'
{% endif %}

uwm port replace:
  file.replace:
    - order: last
    - name: /var/www/html/index.html
    - pattern: :\d{2,}"
    - repl: :{{ uwmport }}"
    - unless: grep {{ uwmport }} /var/www/html/index.html
