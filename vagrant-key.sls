vagrant open key:
  ssh_auth.present:
    - name: vagrant
    - user: virl
    - enc: ssh-rsa
    - source: 'salt://files/authorized_keys'