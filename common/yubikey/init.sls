{% set proxy = salt['pillar.get']('master_proxy:state') %}

yubico-ppa:
  pkgrepo.managed:
    - ppa: yubico/stable
    - refresh_db: True

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
{% if proxy %}
      - 'auth sufficient pam_yubico.so id={{salt['pillar.get']('yubikey:id')}} 
key={{salt['pillar.get']('yubikey:key')}} authfile={{salt['pillar.get']('yubikey:authfile')}} urllist={{salt['pillar.get']('yubikey:urllist')}} capath=/etc/ssl/certs proxy={{salt['pillar.get']('master_proxy:proxy_url')}}' 
{% else %}
      - 'auth sufficient pam_yubico.so id={{salt['pillar.get']('yubikey:id')}} 
key={{salt['pillar.get']('yubikey:key')}} authfile={{salt['pillar.get']('yubikey:authfile')}} urllist={{salt['pillar.get']('yubikey:urllist')}} capath=/etc/ssl/certs'
{% endif %}

enable-challenge-response-auth-in-sshd-config:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: ChallengeResponseAuthentication yes
    - repl: ChallengeResponseAuthentication no
    - require:
      - pkg: libpam-yubico

enable-match-in-sshd-config:
  file.append:
    - name: /etc/ssh/sshd_config
    - text:
      - Match group {{salt['pillar.get']('yubikey:group')}}
      - "  AuthenticationMethods publickey"
      - Match group *,{{salt['pillar.get']('yubikey:group')}}
      - "  AuthenticationMethods publickey,password"
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

custom-pam-yubico-auth:
  file.replace:
    - name: /etc/pam.d/yubi-auth
    - pattern: <pam-yubi-goes-here>
{% if proxy %}
    - repl: 'auth required pam_yubico.so id={{salt['pillar.get']('yubikey:id')}} 
key={{salt['pillar.get']('yubikey:key')}} authfile={{salt['pillar.get']('yubikey:authfile')}} urllist={{salt['pillar.get']('yubikey:urllist')}} capath=/etc/ssl/certs proxy={{salt['pillar.get']('master_proxy:proxy_url')}}' 
{% else %}
    - repl: 'auth required pam_yubico.so id={{salt['pillar.get']('yubikey:id')}} 
key={{salt['pillar.get']('yubikey:key')}} authfile={{salt['pillar.get']('yubikey:authfile')}} urllist={{salt['pillar.get']('yubikey:urllist')}} capath=/etc/ssl/certs'
{% endif %}
    - require:
      - pkg: libpam-yubico
      - file: yubi-auth-replace

custom-pam-yubico-group:
  file.replace:
    - name: /etc/pam.d/yubi-auth
    - pattern: <syncgroup>
    - repl: '{{salt['pillar.get']('yubikey:group')}}'
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

yubi-auth-in-sshd:
  file.prepend:
    - name: /etc/pam.d/sshd
    - text:
      - '@include yubi-auth'
    - require:
      - pkg: libpam-yubico
      - file: yubi-auth-replace
      - file: no-common-auth-in-sshd

restart-ssh-post-yubi-auth:
    service.running:
      - name: ssh
      - watch:
        - file: yubi-auth-replace
