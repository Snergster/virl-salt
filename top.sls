base:
  '*':
    - common.ubuntu

  '^.{9}virledu.info$':
    - match: pcre
    - common.virl

  '^.{9}virl.info$':
    - match: pcre
    - common.virl

  '^.{9}devnet.info$':
    - match: pcre
    - common.virl


  '^.*innopod.info$':
    - match: pcre
    - common.virl


  '.*cisco.com$':
    - match: pcre
    - common.virl
