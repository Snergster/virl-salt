download terraform:
  file.managed:
    - name: /home/virl/terraform_0.6.10_linux_amd64.zip
    - source: https://releases.hashicorp.com/terraform/0.6.9/terraform_0.6.10_linux_amd64.zip
    - source_hash: sha256=d7c07e2bf587257673bae710c776430a8cc5a755a9ad4a2cbae066d0cd02a862
    - unless: terraform --version  | grep 'v0.6.10'
install terraform:
  cmd.run:
    - name: unzip /home/virl/terraform_0.6.10_linux_amd64.zip -d /usr/local/bin
    - unless: terraform --version  | grep 'v0.6.10'
    - require:
      - file: download terraform

remove dead zipfile:
  file.absent:
    - name: /home/virl/terraform_0.6.10_linux_amd64.zip
    - require:
      - cmd: install terraform
