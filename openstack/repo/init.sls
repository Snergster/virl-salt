{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}
{% set kilo = salt['pillar.get']('virl:kilo', salt['grains.get']('kilo', false)) %}

{% if kilo %}
include:
  - openstack.repo.kilo
{% else %}

{% if masterless %}
/etc/apt/sources.list.d/cisco-openstack-mirror_icehouse.list:
  file.copy:
    - source: /srv/salt/virl/files/cisco-openstack-mirror_icehouse.list


/etc/apt/preferences.d/cisco-openstack:
  file.copy:
    - source: /srv/salt/virl/files/cisco-openstack-preferences
    - force: true


/tmp/cisco-openstack.key:
  cmd.run:
    - name: apt-key add /srv/salt/virl/files/cisco-openstack.key


{% else %}

/etc/apt/sources.list.d/cisco-openstack-mirror_icehouse.list:
  file.managed:
    - source: salt://virl/files/cisco-openstack-mirror_icehouse.list


/etc/apt/preferences.d/cisco-openstack:
  file.managed:
    - source: salt://virl/files/cisco-openstack-preferences

/tmp/cisco-openstack.key:
  file.managed:
    - source: salt://virl/files/cisco-openstack.key
  cmd.wait:
    - name: apt-key add /tmp/cisco-openstack.key
    - cwd: /tmp
    - watch:
      - file: /tmp/cisco-openstack.key

{% endif %}
{% endif %}
