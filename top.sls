base:
  '*':
    - common.ubuntu
    - virl.vinstall

  '^.{9}virledu.info$':
    - match: pcre
    - virl.std
    - virl.ank

  '^.{9}virl.info$':
    - match: pcre
    - virl.std
    - virl.ank

  '^.{9}devnet.info$':
    - match: pcre
    - virl.std
    - virl.ank

  '^.*innopod.info$':
    - match: pcre
    - virl.std
    - virl.ank

  '.*cisco.com$':
    - match: pcre
    - virl.std
    - virl.ank
