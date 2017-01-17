libpam-yubico:
  pkg.installed

libykclient3:
  pkg.installed

/etc/yubikeys:
  file.managed:
    - makedirs: True
    - contents_pillar: yubikey:authorized

/etc/pam.d/login:
  file.prepend:
    - require:
      - pkg: libpam-yubico
    - text:
      - 'auth sufficient pam_yubico.so id={{salt['pillar.get']('yubikey:id')}} authfile={{salt['pillar.get']('yubikey:authfile')}}
key={{salt['pillar.get']('yubikey:key')}} url={{salt['pillar.get']('yubikey:url')}}'

enable-challenge-response-auth-in-sshd-config:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ChallengeResponseAuthentication yes
    - repl: ChallengeResponseAuthentication no
    - require:
      - pkg: libpam-yubico

enable-pubkey-and-password-auth-in-sshd-config:
  file.append:
    - name: /etc/ssh/sshd_config
    - text: AuthenticationMethods publickey,password
    - require:
      - pkg: libpam-yubico

disable-rsa-auth-in-sshd-config:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: RSAAuthentication yes
    - repl: RSAAuthentication no
    - require:
      - pkg: libpam-yubico

disable-pubkey-auth-in-sshd-config:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: PubkeyAuthentication no
    - repl: PubkeyAuthentication yes
    - require:
      - pkg: libpam-yubico

enable-password-auth-regex-in-sshd-config:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ^.PasswordAuthentication yes
    - repl: PasswordAuthentication yes
    - require:
      - pkg: libpam-yubico

enable-password-auth-in-sshd-config:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: PasswordAuthentication no
    - repl: PasswordAuthentication yes
    - require:
      - pkg: libpam-yubico

common-auth-replace:
  file.managed:
    - name: /etc/pam.d/common-auth
    - source: 'salt://common/yubikey/files/common-auth'
    - mode: 0644

yubi-auth-replace:
  file.managed:
    - name: /etc/pam.d/yubi-auth
    - source: 'salt://common/yubikey/files/yubi-auth'
    - mode: 0644  

custom-pam-yubico:
  file.replace:
    - name: /etc/pam.d/yubi-auth
    - pattern: <pam-yubi-goes-here>
    - repl: 'auth required pam_yubico.so mode=client id={{salt['pillar.get']('yubikey:id')}} authfile={{salt['pillar.get']('yubikey:authfile')}}
key={{salt['pillar.get']('yubikey:key')}} url={{salt['pillar.get']('yubikey:url')}}'
    - require:
      - pkg: libpam-yubico
      - file: yubi-auth-replace

no-common-auth-in-sshd:
  file.comment:
    - name: /etc/pam.d/sshd
    - regex: ^@include common-auth
    - require:
      - pkg: libpam-yubico
      - file: yubi-auth-replace
      - file: custom-pam-yubico

yubi-auth-in-sshd:
  file.prepend:
    - name: /etc/pam.d/sshd
    - text:
      - '@include yubi-auth'
    - require:
      - pkg: libpam-yubico
      - file: yubi-auth-replace
      - file: no-common-auth-in-sshd