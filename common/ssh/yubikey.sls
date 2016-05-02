{% set yubikey_id = salt['pillar.get']('yubikey:id', salt['grains.get']('yubikey_id', '1111' )) %}
{% set yubikey_key = salt['pillar.get']('yubikey:key', salt['grains.get']('yubikey_key', '1111' )) %}

libpam-yubico:
  pkg.installed

libykclient3:
  pkg.installed

/etc/yubikeys:
  file.managed:
    - makedirs: True
    - contents_pillar: yubikey:authorized

yubikey_backup:
  file.managed:
    - name: /etc/yubikeys
    - makedirs: True
    - contents_grains: yubikey_authorized
    - onfail:
      - file: /etc/yubikeys

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
    - contents: 'auth required pam_yubico.so mode=client id={{yubikey_id}} authfile=/etc/yubikeys key={{yubikey_key}} url=http://api.yubico.com/wsapi/2.0/verify?id=%d&otp=%s'
    - require:
      - pkg: libpam-yubico

/etc/pam.d/login:
  file.prepend:
    - text:
      - auth sufficient pam_yubico.so id={{yubikey_id}} authfile=/etc/yubikeys key={{yubikey_key}} url=http://api.yubico.com/wsapi/2.0/verify?id=%d&otp=%s
    - require:
      - pkg: libpam-yubico

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

password hell yes:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^.PasswordAuthentication no
    - repl: PasswordAuthentication yes
    - require:
      - pkg: libpam-yubico

password fuck yes:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: PasswordAuthentication no
    - repl: PasswordAuthentication yes
    - require:
      - pkg: libpam-yubico

common-auth replace:
  file.managed:
    - name: /etc/pam.d/common-auth
    - source: 'salt://common/ssh/files/common-auth'
    - mode: 0644
