{% set onedev = salt['grains.get']('onedev', '') %}
{% set saltmaster = salt['grains.get']('salt master', 'none') %}
base:
  '*':
    {% if saltmaster == 'none' %}
       - ank-internal
       - std-internal
       - vmm-download-internal
       - virl-install-internal
       - salt-internal
    {% if onedev == true %}
       - onepk-internal
       - vmm-local
       - eclipse-internal
    {% endif %}
    {% else %}
       - ank-external
       - std-external
       - images
       - virl-install-external
       - vmm-download-external
    {% if onedev == true %}
       - onepk-external
       - vmm-local
       - eclipse-external
    {% endif %}
    {% endif %}
