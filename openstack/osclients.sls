{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

nova client:
  pip.installed:
    - skip_verify: True
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - refresh: False
    - name: python-novaclient == 2.20.0

libffi-dev for rackspace:
  pkg.installed:
    - name: libffi-dev


pip clients:
  pip.installed:
    - skip_verify: True
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - refresh: False
    - names:
      - python-glanceclient == 0.15.0
      - python-keystoneclient == 1.0.0
      - python-neutronclient == 2.3.4
      - oslo.config == 1.6.0
      - oslo.rootwrap == 1.5.0
      - oslo.messaging == 1.6.0
    - require:
      - pip: nova client
      - pkg: libffi-dev for rackspace



{% for symlink in ['keystone','neutron','glance','nova']%}
/usr/bin/{{ symlink }}:
  file.symlink:
    - target: /usr/local/bin/{{ symlink }}
    - mode: 0755
    - require:
      - pip: pip clients
    - onlyif:
      - 'test -e /usr/local/bin/{{ symlink }}'
      - 'test ! -e /usr/bin/{{ symlink }}'

{% endfor %}

{% if not masterless %}

{% for holdies in ['python-glanceclient','python-novaclient','python-neutronclient','python-keystoneclient']%}
{{ holdies }} hold:
  file.managed:
    - name: /etc/apt/preferences.d/{{holdies}}
    - require:
      - pip: pip clients
    - contents: |
        Package: {{holdies}}
        Pin: release *
        Pin-Priority: -1

{% endfor %}
{% endif %}

