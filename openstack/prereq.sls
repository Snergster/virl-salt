openstack prereq lock:
  pip.installed:
    - names:
      - oslo.messaging == 1.6.0
      - oslo.middleware == 1.1.0
      - python-novaclient == 2.20.0
      - python-keystoneclient == 1.0.0
      - oslo.config == 1.6.0
      - oslo.rootwrap == 1.5.0
      - pbr == 0.10.8
      - oslo.i18n == 1.6.0
      - oslo.serialization == 1.5.0
      - oslo.utils == 1.5.0