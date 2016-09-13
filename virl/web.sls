{% from "virl.jinja" import virl with context %}


apache dir reset:
  file.directory:
    - name: /var/www/html
    - clean: True
  archive.extracted:
    - name: /var/www/html/
    - archive_format: tar
{% if virl.cml %}
    - source: salt://virl/files/cmlweb.tar
    - source_hash: {{ virl.cmlweb }}
{% else %}
    - source: salt://virl/files/virlweb.tar
    - source_hash: {{ virl.virlweb }}
{% endif %}
    - if_missing: /var/www/html/index.html
    - require:
      - file: apache dir reset

servername prepend:
  file.replace:
    - prepend_if_not_found: False
    - name: /etc/apache2/apache2.conf
    - pattern: ServerName.*
    - repl: 'ServerName {{virl.hostname}}.{{ virl.domain_name }}'

servername for apache in web:
  file.managed:
    - name: /etc/apache2/conf-available/servername.conf
    - contents: |
        ServerName '{{ virl.hostname }}.{{ virl.domain_name }}'

servername symlink in web:
  file.symlink:
    - name: /etc/apache2/conf-enabled/servername.conf
    - target: /etc/apache2/conf-available/servername.conf
    - require:
      - file: servername for apache in web

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

{% if 'xenial' in salt['grains.get']('oscodename') %}

a2enmod-enable:
  cmd.run:
    - names: 
      - a2enmod proxy
      - a2enmod rewrte
      - a2enmod proxy_http

/etc/apache2/sites-enabled/000-default.conf:
  file.managed:
    - mode: 755
    - template: jinja
    - source: salt://virl/files/mitaka.000-default.conf

{% else %}

/etc/apache2/sites-enabled/000-default.conf:
  file.managed:
    - mode: 755
    - template: jinja
    - source: salt://virl/files/000-default.conf

{% endif %}

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
