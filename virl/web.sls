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

apache dir remove:
  file.directory:
    - name: /var/www/html
    - clean: True
  cmd.run:
    - name: /bin/tar -xf /srv/salt/virl/files/cmlweb.tar -C /var/www/html
    - onlyif: test ! -e /var/www/html/index.html

{% else %}

apache dir remove:
  file.directory:
    - name: /var/www/html
    - clean: True
  archive.extracted:
    - name: /var/www/html/
    - source: salt://virl/files/virlweb.tar
    - source_hash: md5=706be2a49e1e38df8596c21121697cea
    - if_missing: /var/www/html/index.html
    - require:
      - file: apache dir remove

{% endif %}

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
