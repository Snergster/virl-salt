{% for dir in ['openstack','virl','_modules','states','common'] %}
{{ dir }} sls locally:
  file.recurse:
    - clean: True
    - name: /srv/salt/{{dir}}
    - source: salt://salt/{dir}
{% endfor %}

## copy sls locally old:
##   file.recurse:
##     - clean: True
##     - name: /srv/salt/openstack
##     - source: salt://openstack

## copy dash virlweb:
##   file.recurse:
##     - clean: True
##     - require:
##       - file: copy sls locally
##     - name: /srv/salt/openstack/dash/files
##     - source: salt://files/virlweb
