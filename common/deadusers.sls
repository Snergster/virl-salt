
{# cheap and ugly dead letter office...yuck ick #}

{% for username, user in pillar.get('deadusers', {}).items() %}
{{ username }}:

  group:
    - absent
    - name: {{ username }}

  user:
    - absent
    - purge: False
    - name: {{ username }}


  {% if 'sudo' in user %}
  file.absent:
    - name: /etc/sudoers.d/{{ username }}
  {% endif %}

{% endfor %}
