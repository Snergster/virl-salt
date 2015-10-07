{% for each in ['ank-cisco-webserver','virl-vis-webserver','virl-vis-processor','virl-vis-mux']%}
{{each}} dead:
  service.dead:
    - name: {{each}}
{% endfor %}

ank remove:
  pip.removed:
    - names:
      - autonetkit
      - autonetkit-cisco
      - autonetkit-cisco-webui
      - virl-collection


ank cache cleanup:
  cmd.run:
    - names:
      - 'rm -f /var/cache/virl/ank/auto*'
      - 'rm -f /var/cache/virl/ank/virl*'
