{% set value = salt['cmd.run']('cat ~virl/.ssh/id_rsa.pub', '') %}
virl_ssh_key:
  grains.present:
    - value: {{value}}
