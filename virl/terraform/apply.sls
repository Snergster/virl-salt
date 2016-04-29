{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set ifproxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}

{% set path = '/home/virl/virl_packet' %}

include:
  # update salt keys and configuration
  - virl.terraform.save

{% if ifproxy == True %}
http_proxy:
  environ.setenv:
    - value: {{ http_proxy }}
{% endif %}

validate:
  cmd.run:
    - name: terraform plan -no-color {{ path }}

launch:
  cmd.run:
    - name: terraform apply -no-color {{ path }}
    - require:
      - cmd: validate

terminate:
  cmd.run:
    - name: terraform destroy -no-color -force {{ path }} || terraform destroy -no-color -force {{ path }}
    - onfail:
      - cmd: launch
