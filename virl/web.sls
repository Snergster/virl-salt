{% set uwmport = salt['pillar.get']('virl:virl_user_management', salt['grains.get']('virl_user_management', '19400')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}


apache dir reset:
  file.directory:
    - name: /var/www/html
    - clean: True
  archive.extracted:
    - name: /var/www/html/
    - archive_format: tar
{% if cml %}
    - source: salt://virl/files/cmlweb.tar
    - source_hash: md5=d67f85b69bc80bb1ac4e2592d20a4c83
{% else %}
    - source: salt://virl/files/virlweb.tar
    - source_hash: md5=706be2a49e1e38df8596c21121697cea
{% endif %}
    - if_missing: /var/www/html/index.html
    - require:
      - file: apache dir reset

servername prepend:
  file.replace:
    - prepend_if_not_found: True
    - name: /etc/apache2/apache2.conf
    - pattern: ServerName.*
    - repl: 'ServerName {{salt['grains.get']('hostname', 'virl')}}.{{salt['grains.get']('domain_name', 'virl.info')}}'

/etc/apache2/sites-enabled/apache.conf:
  file.managed:
    - mode: 755
    - source: salt://virl/files/apache.conf

/etc/apache2/ports.conf:
  file.managed:
    - mode: 755
    - template: jinja
    - source: salt://virl/files/ports.conf

/etc/apache2/sites-enabled/000-default.conf:
  file.managed:
    - mode: 755
    - template: jinja
    - source: salt://virl/files/000-default.conf

restart apache:
  service.running:
    - name: apache2
    - watch:
      - file: /etc/apache2/sites-enabled/apache.conf
      - file: /etc/apache2/ports.conf
      - file: /etc/apache2/sites-enabled/000-default.conf
      - archive: apache dir reset

apache failsafe killer:
  service.dead:
    - name: apache2
    - onfail:
      - service: restart apache

apache failsafe restart:
  service.running:
    - name: apache2
    - watch:
      - service: apache failsafe killer
