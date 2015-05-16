{% set cml = salt['pillar.get']('virl:cml', salt['grains.get']('cml', false )) %}
{% set masterless = salt['pillar.get']('virl:salt_masterless', salt['grains.get']('salt_masterless', false)) %}

{% set desktop_manager = salt['pillar.get']('virl:desktop_manager', salt['grains.get']('desktop_manager', 'lubuntu')) %}

include:
{% if desktop_manager = 'lxde' %}
  - virl.desktop.lxde
{% else %}
  - virl.desktop.lubuntu
{% endif %}
