{% from "virl.jinja" import virl with context %}

{% if virl.proxy %}
http_proxy std prereq:
  environ.setenv:
    - name: http_proxy
    - value: {{ virl.http_proxy }}

https_proxy std prereq:
  environ.setenv:
    - name: https_proxy
    - value: {{ virl.http_proxy }}

{% endif %}

{% if virl.mitaka %}

include:
  - virl.routervms.virl-core-sync

{% endif %}

std prereq pkgs:
  pkg.installed:
{% if virl.packet %}
      - refresh: True
{% endif %}
      - pkgs:
        - libxml2-dev
        - libxslt1-dev
        - python-faulthandler

libc6-i386-sans-pkg:
  cmd.run:
    - name: 'apt-get install -qq libc6:i386'

std_prereq_webmux:
  pip.installed:
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
    - names:
      - cryptography >= 1.1
      - docker-py >= 1.3.1
      - ipaddr >= 2.1.11
      - flask-sqlalchemy >= 2.0
      - Flask >= 0.10.1
      - Flask_Login >= 0.3.0
      - Flask_RESTful >= 0.3.5
      - Flask_WTF >= 0.14
      - Flask_Breadcrumbs >= 0.3.0
      - flask-compress
      - Flask_Cors
      - itsdangerous >= 0.24
      - Jinja2 >= 2.7.3
      - lxml >= 3.4.1, < 3.6.0
      - MarkupSafe >= 0.23
      - mock >= 1.0.1
      - paramiko >= 2.1.1
      - pycrypto >= 2.6.1
      - Pygments
      - requests == 2.7.0
      - redis >= 2.10.5
      - setproctitle
      - simplejson >= 3.6.5
      {% if virl.mitaka %}
      - sqlalchemy < 1.1.0
      {% endif %}
      {% if virl.kilo %}
      - sqlalchemy == 0.9.9
      {% endif %}
      - websocket_client >= 0.26.0
      - Werkzeug >= 0.10.1
      - wsgiref
      - WTForms >= 2.0.2
      - WTForms-JSON == 0.3.0
      - tornado >= 3.2.2
    - require:
      - pkg: 'std prereq pkgs'
