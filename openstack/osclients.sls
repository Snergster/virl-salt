{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set proxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set ospassword = salt['pillar.get']('virl:password', salt['grains.get']('password', 'password')) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

include:
  - openstack.keystone
  - openstack.nova.install
  - openstack.neutron
  - openstack.glance

libffi-dev for rackspace:
  pkg.installed:
    - name: libffi-dev


oslo messaging first:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - require:
      - pkg: nova-pkgs
      - pkg: libffi-dev for rackspace
    - names:
      - oslo.messaging == 1.6.0

nova client:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - names:
      - oslo.middleware == 1.1.0
      - python-novaclient == 2.20.0
      - oslo.config == 1.6.0
      - oslo.rootwrap == 1.5.0
      - pbr == 0.10.8
  file.managed:
    - name: /etc/apt/preferences.d/python-novaclient
    - require:
      - pip: nova client
    - contents: |
        Package: python-novaclient
        Pin: release *
        Pin-Priority: -1



neutron client:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - require:
      - pkg: neutron-pkgs
      - pip: nova client
    - names:
      - python-neutronclient == 2.3.4
  file.managed:
    - name: /etc/apt/preferences.d/python-neutronclient
    - require:
      - pip: neutron client
    - contents: |
        Package: python-neutronclient
        Pin: release *
        Pin-Priority: -1


glance client:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - require:
      - pkg: glance-pkgs
      - pip: nova client
    - names:
      - python-glanceclient == 0.15.0
  file.managed:
    - name: /etc/apt/preferences.d/python-glanceclient
    - require:
      - pip: glance client
    - contents: |
        Package: python-glanceclient
        Pin: release *
        Pin-Priority: -1

keystone client:
  pip.installed:
{% if proxy == true %}
    - proxy: {{ http_proxy }}
{% endif %}
    - require:
      - pkg: keystone-pkgs
      - pip: nova client
    - names:
      - python-keystoneclient == 1.0.0
      - oslo.i18n == 1.6.0
      - oslo.serialization == 1.5.0
      - oslo.utils == 1.5.0

  file.managed:
    - name: /etc/apt/preferences.d/python-keystoneclient
    - require:
      - pip: keystone client
    - contents: |
        Package: python-keystoneclient
        Pin: release *
        Pin-Priority: -1


{% for symlink in ['keystone','neutron','glance','nova']%}
/usr/bin/{{ symlink }}:
  file.symlink:
    - target: /usr/local/bin/{{ symlink }}
    - mode: 0755
    - onlyif:
      - 'test -e /usr/local/bin/{{ symlink }}'
      - 'test ! -e /usr/bin/{{ symlink }}'

{% endfor %}
