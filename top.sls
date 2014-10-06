{% set onedev = salt['grains.get']('onedev', '') %}
base:
  '*':
       - ank
       - std
       - vinstall
       - vmm-download
       - routervms
    {% if onedev == true %}
       - onepk-install
       - vmm-local
       - eclipse
    {% endif %}
