
{% from "virl.jinja" import virl with context %}


{% set std_ver_fixed = salt['pillar.get']('behave:std_ver_fixed', salt['grains.get']('std_ver_fixed', False)) %}
{% set std_ver = salt['pillar.get']('behave:std_ver', salt['grains.get']('std_ver', '0.10.10.18')) %}
{% set venv = salt['pillar.get']('behave:environment', 'stable') %}


{% set compute1 = salt['grains.get']('compute1_hostname', 'compute1' ) %}
{% set compute2 = salt['grains.get']('compute2_hostname', 'compute2' ) %}
{% set compute3 = salt['grains.get']('compute3_hostname', 'compute3' ) %}
{% set compute4 = salt['grains.get']('compute4_hostname', 'compute4' ) %}
{% set download_proxy = salt['pillar.get']('virl:download_proxy', salt['grains.get']('download_proxy', '')) %}
{% set download_no_proxy = salt['pillar.get']('virl:download_no_proxy', salt['grains.get']('download_no_proxy', '')) %}
{% set download_proxy_user = salt['pillar.get']('virl:download_proxy_user', salt['grains.get']('download_proxy_user', '')) %}
{% set host_simulation_port_min_tcp = salt['pillar.get']('virl:host_simulation_port_min_tcp', salt['grains.get']('host_simulation_port_min_tcp', '10000')) %}
{% set host_simulation_port_max_tcp = salt['pillar.get']('virl:host_simulation_port_max_tcp', salt['grains.get']('host_simulation_port_max_tcp', '17000')) %}


std prereq pkgs:
  pkg.installed:
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
      - Twisted >= 13.2.0
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
