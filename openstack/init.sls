{% for dir in ['openstack','virl','_modules','_states','common'] %}
{{ dir }} sls locally:
  file.recurse:
    - clean: True
    - name: /srv/salt/{{dir}}
    - source: salt://{{dir}}
{% endfor %}

