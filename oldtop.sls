{% set onedev = salt['grains.get']('onedev', '') %}
{% set saltmaster = salt['grains.get']('salt master', 'none') %}
base:
  '*':
    {% if grains['inside cisco?'] == true %}
       - ank-internal
       - std-internal
       - vmm-download-internal
       - virl-install-internal
       - salt-internal
    {% if grains['onedev'] == true %}
       - onepk-internal
       - vmm-local
       - eclipse-internal
    {% endif %}
    {% elif not grains['salt master'] == 'none' %}
       - ank-external
       - std-external
       - images
       - virl-install-external
       - vmm-download-external
    {% if grains['onedev'] == true %}
       - onepk-external
       - vmm-local
       - eclipse-external
    {% endif %}
    {% endif %}
