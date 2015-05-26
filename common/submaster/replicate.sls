include:
  - common.salt-master.reactor

first attempt:
  git.latest:
    - name: https://github.com/Snergster/virl-salt.git
    - target: /srv/salt

just in case:
  git.latest:
    - target: /srv/salt
    - name: https://github.com/Snergster/virl-salt.git
    - force: True
    - onfail:
      - git: first attempt

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

{% if salt['pillar.get']('common:branch:qa', False) %}

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