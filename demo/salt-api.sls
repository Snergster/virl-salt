
salt-api:
  pip.installed:
    - name: salt-api
  {% if salt['grains.get']('proxy', 'False') %}
    - proxy: {{salt['grains.get']('http proxy', 'None')}}

