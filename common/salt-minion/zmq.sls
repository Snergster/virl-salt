
libzmq upgrade:
  pkgrepo.managed:
    - ppa: chris-lea/zeromq
  pkg.latest:
    - name: libzmq3-dev
    - refresh: True
