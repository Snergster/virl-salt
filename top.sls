base:
  '*':
    - common.virl

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
    - virl.vmm.download

  '.*cisco.com$':
    - match: pcre
    - virl.std
    - virl.ank
    - virl.vmm.download
