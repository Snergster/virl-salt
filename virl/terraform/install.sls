{% if salt['grains.get']('cpuarch') != 'x86_64' %}

download terraform:
  file.managed:
    - name: /home/virl/terraform_0.6.12_linux_amd64.zip
    - source: https://releases.hashicorp.com/terraform/0.6.12/terraform_0.6.12_linux_386.zip
    - source_hash: sha256=c936e073988cef78dd1c1d29873276f85a7ec44329074bc353a022054fbd5e06
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
    - source_hash: sha256=37513aba20f751705f8f98cd0518ebb6a4a9c2148453236b9a5c30074e2edd8d
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