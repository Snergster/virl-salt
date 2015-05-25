libpam-yubico:
  pkg.installed

libykclient3:
  pkg.installed

/etc/yubikeys:
  file.managed:
    - makedirs: True
    - contents_pillar: yubikey:authorized

common auth out:
  file.comment:
    - name: /etc/pam.d/sshd
    - regex: ^@include common-auth
    - require:
      - pkg: libpam-yubico
      - file: /etc/pam.d/yubi-auth

yubi auth in:
  file.prepend:
    - name: /etc/pam.d/sshd
    - text:
      - '@include yubi-auth'
    - require:
      - pkg: libpam-yubico
      - file: /etc/pam.d/yubi-auth
      - file: common auth out

/etc/pam.d/yubi-auth:
  file.managed:
    - contents: 'auth required pam_yubico.so mode=client id={{salt['pillar.get']('yubikey:id')}} authfile={{salt['pillar.get']('yubikey:authfile')}}
key={{salt['pillar.get']('yubikey:key')}} url={{salt['pillar.get']('yubikey:url')}}'
    - require:
      - pkg: libpam-yubico

/etc/pam.d/login:
  file.prepend:
    - require:
      - pkg: libpam-yubico
    - text:
      - auth sufficient pam_yubico.so id={{salt['pillar.get']('yubikey:id')}} authfile={{salt['pillar.get']('yubikey:authfile')}}
key={{salt['pillar.get']('yubikey:key')}} url={{salt['pillar.get']('yubikey:url')}}


challenge yes:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ChallengeResponseAuthentication yes
    - repl: ChallengeResponseAuthentication no
    - require:
      - pkg: libpam-yubico

multichallenge:
  file.append:
    - name: /etc/ssh/sshd_config
    - text: AuthenticationMethods publickey,password
    - require:
      - pkg: libpam-yubico

rsa no:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: RSAAuthentication yes
    - repl: RSAAuthentication no
    - require:
      - pkg: libpam-yubico

pubkey no:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: PubkeyAuthentication no
    - repl: PubkeyAuthentication yes
    - require:
      - pkg: libpam-yubico

password yes:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^.PasswordAuthentication yes
    - repl: PasswordAuthentication yes
    - require:
      - pkg: libpam-yubico

password fuck yes:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^.PasswordAuthentication yes
    - repl: PasswordAuthentication yes
    - require:
      - pkg: libpam-yubico

common-auth replace:
  file.managed:
    - name: /etc/pam.d/common-auth
    - source: 'salt://common/yubikey/files/common-auth'
    - mode: 0644