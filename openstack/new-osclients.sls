nova client:
  pip.installed:
    - skip_verify: True
    - upgrade: True
    - refresh: False
    - name: python-novaclient


pip clients:
  pip.installed:
    - skip_verify: True
    - refresh: False
    - names:
      - python-glanceclient == 0.15.0
      - python-keystoneclient == 1.0.0
      - python-neutronclient == 2.3.4
      - oslo.rootwrap == 1.5.0
      - oslo.messaging == 1.6.0
    - require:
      - pip: nova client

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
