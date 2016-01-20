download terraform:
  file.managed:
    - name: /home/virl/terraform_0.6.9_linux_amd64.zip
    - source: https://releases.hashicorp.com/terraform/0.6.9/terraform_0.6.9_linux_amd64.zip
    - source_hash: sha256=c7d3e76de165be9f47eff8f54b41bb873f6f1881d2fb778a54bb8aaf69abfae6
install terraform:
  cmd.run:
    - name: unzip terraform_0.6.9_linux_amd64.zip -d /usr/local/bin
    - unless: terraform --version  | grep 'v0.6.9'
