
{% from "virl.jinja" import virl with context %}


prereq_redis:
  pip.installed:
  {% if virl.proxy %}
    - proxy: {{ virl.http_proxy }}
  {% endif %}
    - name: redis

virl_tap_counter_init:
  file.managed:
    - name: /etc/init.d/virl-tap-counter
    - source: "salt://virl/std/files/virl-tap-counter.init"
    - mode: 0755

virl_tap_counter_exec:
  file.managed:
    - name: /usr/local/bin/virl_tap_counter
    - source: "salt://virl/std/files/virl_tap_counter"
    - mode: 0755

virl_tap_counter_conf:
  file.managed:
    - name: /etc/default/virl_tap_counter
    - mode: 0755
    - contents: |
        # Defaults for virl_tap_counter
        # This file is sourced in /etc/init.d/virl-tap-counter
        # Address of redis instance to send data to
        {% if virl.controller  %}
        TC_ADDRESS="localhost"
        {% else %}
        TC_ADDRESS="{{ virl.controller_ip }}"
        {% endif %}
        # Port of redis instance to send data to
        TC_PORT="6379"
        # How often to check for new interfaces
        TC_GLOB_INTERVAL="15"
        # How often to read values
        TC_POLL_INTERVAL="1"
        # How long will each redis record last before expiry
        TC_TTL="600"
        # Limit for open filehandles. One interface accounts for 4 filehandles
        ULIMIT="16384"


{% if virl.controller %}
redis-server:
  pkg.installed:
    - pkg: redis-server

redis-bind:
  file.replace:
    - name: /etc/redis/redis.conf
    - pattern: '^bind .*'
    - repl: ''
    - require:
      - pkg: redis-server

redis-running:
  service.running:
    - name: redis-server
    - enable: True
    - watch:
      - pkg: redis-server
{% endif %}

virl-tap-counter:
  service.running:
    - enable: True
    - reload: True
