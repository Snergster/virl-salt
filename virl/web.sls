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

/srv/salt/virl/files/virlweb.tar:
  file.managed:
    - source: 'salt://virl/files/virlweb.tar'
    - mode: 755
    - user: virl
    - group: virl

apache dir remove:
  file.directory:
    - name: /var/www/html
    - clean: True
    - onchanges:
      - file: /srv/salt/virl/files/virlweb.tar
  cmd.run:
    - name: /bin/tar -xf /srv/salt/virl/files/virlweb.tar -C /var/www/html
    - onlyif: test ! -e /var/www/html/index.html


{% endif %}

/etc/apache2/sites-enabled/apache.conf:
  file.managed:
    - mode: 755
    {% if masterless %}
    - source: file:///srv/salt/virl/files/apache.conf
    - source_hash: md5=9a5af69e63deafbe92fc2e9d5bca5839
    {% else %}
    - source: salt://virl/files/apache.conf
    {% endif %}

/etc/apache2/ports.conf:
  file.managed:
    - mode: 755
    - template: jinja
    {% if masterless %}
    - source: file:///srv/salt/virl/files/ports.conf
    {% else %}
    - source: salt://virl/files/ports.conf
    {% endif %}

/etc/apache2/sites-enabled/000-default.conf:
  file.managed:
    - mode: 755
    - template: jinja
    {% if masterless %}
    - source: file:///srv/salt/virl/files/000-default.conf
    {% else %}
    - source: salt://virl/files/000-default.conf
    {% endif %}

restart apache:
  cmd.run:
    - name: /etc/init.d/apache2 restart

