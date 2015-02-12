{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}

nova client:
  pip.installed:
    - skip_verify: True
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - upgrade: True
    - refresh: False
    - name: python-novaclient


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
      - oslo.rootwrap == 1.5.0
      - oslo.messaging == 1.6.0
    - require:
      - pip: nova client

python-pip:
  pkg.removed:
    - name: python-pip
    - hold: True
    - require:
      - pip: pip clients

{% for symlink in ['pip','keystone','neutron','glance','nova']%}
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

{% for holdies in ['python-glanceclient','python-novaclient','python-neutronclient','python-keystoneclient','python-pip']%}
{{ holdies }} hold:
  apt.held:
    - name: {{ holdies }}
{% endfor %}
