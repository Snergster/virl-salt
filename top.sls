base:
  '*':
    - common.ubuntu

  '^.{9}virledu.info$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '^.{9}virl.info$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '^.{9}devnet.info$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '^.*innopod.info$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '.*cisco.com$':
    - match: pcre
    - common.virl
    - virl.vinstall

  '.*packet.net$':
    - match: pcre
    - common.users
    - common.get-pip
    - common.salt-minion
    - common.virl
    - virl.basics
    - common.bridge

  'appcat.virl.qa$':
    - match: pcre
    - common.salt-minion
    - virl.basics
    - common.virl
    - openstack
    - common.bridge

