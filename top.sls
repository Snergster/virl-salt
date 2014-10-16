base:
  '*':
    - common.ubuntu
    - vinstall

  '^.{9}virledu.info$':
    - match: pcre
    - std
    - ank
    - routervms

  '^.{9}virl.info$':
    - match: pcre
    - std
    - ank
    - routervms

  '^.{9}devnet.info$':
    - match: pcre
    - std
    - ank
    - routervms

  '^.*innopod.info$':
    - match: pcre
    - std
    - ank
    - routervms

  '.*cisco.com$':
    - match: pcre
    - common.virl
