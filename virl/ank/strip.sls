{% for each in ['ank-cisco-webserver','virl-vis-webserver','virl-vis-processor','virl-vis-mux']%}
{{each}} dead:
  service.dead:
    - name: {{each}}
{% endfor %}
{% for ank in ['autonetkit','autonetkit-cisco','autonetkit-cisco-webui','virl-collection']%}
{{ank}} remove:
  pip.removed:
    - name: {{ank}}
{%endfor%}