
{# I really should dep this in favor of the users forumula but thats more then I need right now #}

{% for username, user in pillar.get('users', {}).items() %}
{{ username }}:

  group:
    - present
    - name: {{ username }}

  user:
    - present
    - fullname: {{ user['fullname'] }}
    - name: {{ username }}
    - shell: /bin/bash
    - home: /home/{{ username }}
    - password: {{ user['crypt'] }}
    {% if 'groups' in user %}
    - groups:
      {% for group in user['groups'] %}
      - {{ group }}
      {% endfor %}
    # - require:
    #   {% for group in user['groups'] %}
    #   - group: {{ group }}
    #   {% endfor %}
    {% endif %}

  {% if 'pub_ssh_keys' in user %}
  ssh_auth:
    - present
    - user: {{ username }}
    - names:
    {% for pub_ssh_key in user['pub_ssh_keys'] %}
      - {{ pub_ssh_key }}
    {% endfor %}
    - require:
      - user: {{ username }}
  {% endif %}

  {% if 'sudo' in user %}
  file.managed:
    - name: /etc/sudoers.d/{{ username }}
    - mode: 0400
    - contents_pillar: users:{{username}}:sudo
  {% endif %}

{% endfor %}
