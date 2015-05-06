include:
  - common.rc-local.sls


/usr/local/bin/v6off jinja:
  file.managed:
    - name: /usr/local/bin/v6off.sh
    - mode: 755
    - source: salt://virl/files/v6off.sh
    - template: jinja

avahi no upstart:
  file.managed:
    - name: /etc/init/avahi-daemon.override
    - contents: |
        start on manual
        stop on manual

{% if salt['pillar.get']('virl:using_dhcp_on_the_public_port', salt['grains.get']('using_dhcp_on_the_public_port', True )) %}
network-manager no upstart:
  file.managed:
    - name: /etc/init/network-manager.override
    - contents: |
        start on manual
        stop on manual
{% else %}
network-manager no upstart:
  file.managed:
    - name: /etc/init/network-manager.override
    - contents: |
        start on manual
        stop on manual
{% endif %}

v6off-rclocal:
  file.blockreplace:
    - name: /etc/rc.local
    - marker_start: "# 002s v6off"
    - marker_end: "# 002e"
    - content: |
             /usr/local/bin/v6off.sh

