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
    - onchanges:
      - file: /srv/salt/virl/files/cmlweb.tar
  cmd.wait:
    - name: /bin/tar -xf /srv/salt/virl/files/cmlweb.tar -C /var/www/html
    - watch:
      - file: apache dir remove

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
  cmd.wait:
    - name: tar -xf /srv/salt/virl/files/virlweb.tar -C /var/www/html
    - watch:
      - file: apache dir remove

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
