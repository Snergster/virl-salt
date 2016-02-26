{% if salt['grains.get']('cpuarch') != 'x86_64' %}

download terraform:
  file.managed:
    - name: /home/virl/terraform_0.6.12_linux_386.zip
    - source: https://releases.hashicorp.com/terraform/0.6.12/terraform_0.6.12_linux_386.zip
    - source_hash: https://releases.hashicorp.com/terraform/0.6.12/terraform_0.6.12_SHA256SUMS
    - unless: terraform --version  | grep 'v0.6.12'
install terraform:
  cmd.run:
    - name: unzip -o /home/virl/terraform_0.6.12_linux_386.zip -d /usr/local/bin
    - unless: terraform --version  | grep 'v0.6.12'
    - require:
      - file: download terraform

remove dead zipfile:
  file.absent:
    - name: /home/virl/terraform_0.6.12_linux_386.zip
    - require:
      - cmd: install terraform

{% else %}

download terraform:
  file.managed:
    - name: /home/virl/terraform_0.6.12_linux_amd64.zip
    - source: https://releases.hashicorp.com/terraform/0.6.12/terraform_0.6.12_linux_amd64.zip
    - source_hash: https://releases.hashicorp.com/terraform/0.6.12/terraform_0.6.12_SHA256SUMS
    - unless: terraform --version  | grep 'v0.6.12'
install terraform:
  cmd.run:
    - name: unzip -o /home/virl/terraform_0.6.12_linux_amd64.zip -d /usr/local/bin
    - unless: terraform --version  | grep 'v0.6.12'
    - require:
      - file: download terraform

remove dead zipfile:
  file.absent:
    - name: /home/virl/terraform_0.6.12_linux_amd64.zip
    - require:
      - cmd: install terraform

{% endif %}