{% set onedev = salt['grains.get']('onedev', '') %}
base:
  '*':
       - ank
       - std
       - vinstall
       - vmm-download
       - images
    {% if onedev == true %}
       - onepk-install
       - vmm-local
       - eclipse
    {% endif %}

