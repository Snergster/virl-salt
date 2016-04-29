{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set ifproxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}

{% set path = '/home/virl/virl_packet' %}

include:
  # update configuration (salt keys irrelevant for destroying)
  - virl.terraform.save

{% if ifproxy == True %}
http_proxy:
  environ.setenv:
    - value: {{ http_proxy }}
{% endif %}

terminate:
  cmd.run:
    - name: terraform destroy -no-color -force {{ path }} || terraform destroy -no-color -force {{ path }}
