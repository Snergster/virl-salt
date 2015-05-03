CherryPy:
  pip.installed:
    - name: CherryPy
  {% if salt['grains.get']('proxy', 'False') %}
    - proxy: {{salt['grains.get']('http proxy', 'None')}}

