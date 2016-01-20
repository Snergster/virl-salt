include:
  - common.salt-master.reactor
  - common.submaster.salt_sync

{% for each in 'vmm','ank','std' %}
/srv/salt2/{{ each }}/stable:
  file.recurse:
    - source: 'salt://virl/{{each}}/stable'
    - clean: True
    - user: virl
    - makedirs: True
    - group: virl
    - file_mode: 755
    - include_empty: True

{% endfor %}

{% if salt['pillar.get']('branch:qa', False) %}

  {% for each in 'vmm','ank','std' %}
/srv/salt2/{{ each }}/qa:
  file.recurse:
    - source: 'salt://virl/{{each}}/qa'
    - clean: True
    - user: virl
    - makedirs: True
    - group: virl
    - file_mode: 755
    - include_empty: True

  {% endfor %}
{% endif %}