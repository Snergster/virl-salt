{% for each in ['virl-vis-webserver','virl-vis-processor']%}
{{each}} dead:
  service.dead:
    - name: {{each}}
    - enable: false
{% endfor %}

ank remove:
  pip.removed:
    - name: virl-collection


ank cache cleanup:
  cmd.run:
    - names:
      - 'rm -f /var/cache/virl/ank/auto*'
      - 'rm -f /var/cache/virl/ank/virl*'
