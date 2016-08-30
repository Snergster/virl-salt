
{% from "virl.jinja" import virl with context %}

{% if virl.mitaka %}

include:
  - virl.routervms.virl-core-sync

{% endif %}


{% if virl.packet %}
add i386 arch support:
  cmd.run:
    - name: 'dpkg --add-architecture i386'

{% endif %}

std prereq pkgs:
  pkg.installed:
{% if virl.packet %}
      - refresh: True
{% endif %}
      - pkgs:
        - libxml2-dev
        - libxslt1-dev
        - libc6:i386

std_prereq_webmux:
  pip.installed:
  {% if virl.proxy %}
    - proxy: {{ virl.http_proxy }}
  {% endif %}
    - require:
      - pkg: std prereq pkgs
    - names:
      - Twisted < 16.3
      - parse >= 1.4.1
      - stuf >= 0.9.4
      - txsockjs >= 1.2.1
      - zope.interface >= 4.1.0
      - SQLObject >= 1.5.1
      - service_identity
      - docker-py >= 1.3.1
      - lxml >= 3.4.1, < 3.6.0


std_prereq:
  pip.installed:
{% if virl.proxy %}
    - proxy: {{ virl.http_proxy }}
{% endif %}
    - names:
      - docker-py >= 1.3.1
      - ipaddr >= 2.1.11
      - flask-sqlalchemy >= 2.0
      - Flask >= 0.10.1
      - Flask_Login >= 0.3.0
      - Flask_RESTful >= 0.3.2
      - Flask_WTF >= 0.11
      - Flask_Breadcrumbs >= 0.3.0
      - flask-compress
      - Flask_Cors
      - itsdangerous >= 0.24
      - Jinja2 >= 2.7.3
      - lxml >= 3.4.1, < 3.6.0
      - MarkupSafe >= 0.23
      - mock >= 1.0.1
      - paramiko >= 1.15.2, < 2.0.0
      - pycrypto >= 2.6.1
      - Pygments
      - requests == 2.7.0
      - redis >= 2.10.5
      - simplejson >= 3.6.5
      - sqlalchemy == 0.9.9
      - websocket_client >= 0.26.0
      - Werkzeug >= 0.10.1
      - wsgiref
      - WTForms >= 2.0.2
      - WTForms-JSON >= 0.2.10
      - tornado >= 3.2.2
      - require:
        - pkg: 'std prereq pkgs'
