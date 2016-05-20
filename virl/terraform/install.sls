
{% set http_proxy = salt['pillar.get']('virl:http_proxy', salt['grains.get']('http_proxy', 'https://proxy.esl.cisco.com:80/')) %}
{% set ifproxy = salt['pillar.get']('virl:proxy', salt['grains.get']('proxy', False)) %}
{% set terraform_version = salt['pillar.get']('version:terraform', '0.6.16') %}

{% if ifproxy == True %}
http_proxy:
  environ.setenv:
    - value: {{ http_proxy }}
{% endif %}

{% if salt['grains.get']('cpuarch') != 'x86_64' %}

download terraform:
  file.managed:
    - name: /home/virl/terraform_{{ terraform_version }}_linux_386.zip
    - source: https://releases.hashicorp.com/terraform/{{ terraform_version }}/terraform_{{ terraform_version }}_linux_386.zip
    - source_hash: https://releases.hashicorp.com/terraform/{{ terraform_version }}/terraform_{{ terraform_version }}_SHA256SUMS
    - unless: terraform --version  | grep 'v{{ terraform_version }}'
install terraform:
  cmd.run:
    - name: unzip -o /home/virl/terraform_{{ terraform_version }}_linux_386.zip -d /usr/local/bin
    - unless: terraform --version  | grep 'v{{ terraform_version }}'
    - require:
      - file: download terraform

remove dead zipfile:
  file.absent:
    - name: /home/virl/terraform_{{ terraform_version }}_linux_386.zip
    - require:
      - cmd: install terraform

{% else %}

download terraform:
  file.managed:
    - name: /home/virl/terraform_{{ terraform_version }}_linux_amd64.zip
    - source: https://releases.hashicorp.com/terraform/{{ terraform_version }}/terraform_{{ terraform_version }}_linux_amd64.zip
    - source_hash: https://releases.hashicorp.com/terraform/{{ terraform_version }}/terraform_{{ terraform_version }}_SHA256SUMS
    - unless: terraform --version  | grep 'v{{ terraform_version }}'
install terraform:
  cmd.run:
    - name: unzip -o /home/virl/terraform_{{ terraform_version }}_linux_amd64.zip -d /usr/local/bin
    - unless: terraform --version  | grep 'v{{ terraform_version }}'
    - require:
      - file: download terraform

remove dead zipfile:
  file.absent:
    - name: /home/virl/terraform_{{ terraform_version }}_linux_amd64.zip
    - require:
      - cmd: install terraform

{% endif %}