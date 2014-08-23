{% set onedev = salt['grains.get']('onedev', 'False') %}

/home/virl/images:
  file.recurse:
    - file_mode: 755
    - dir_mode: 755
    - user: virl
    - group: virl
    {% if grains['cml?'] == True %}
    - source: "salt://images/cml/"
    {% else %}
    - source: "salt://images/full/"
    {% endif %}

{% if grains['cml?'] == True %}
cmlimages:
  cmd.run:
    - name: /home/virl/files/images/cml.install-list-auto
    - cwd: /home/virl/images
    - user: virl
    - group: virl


{% elif grains['cml?'] == False %}
virlimages:
  cmd.run:
    - name: /home/virl/images/install-list-auto
    - cwd: /home/virl/images
{% endif %}

/usr/local/bin/update_images:
  file.managed:
    - order: 1
    - file_mode: 755
    - source: "salt://files/install_scripts/update_images"
