install basics:
  salt.state:
    - tgt: '*'
    - sls:
      - virl.virluser
      - common.virl
      - virl.basics

get grains in place:
  salt.function:
    - tgt: '*'
    - name: cmd.run
    - arg:
      - /usr/local/bin/vinstall salt

host basics:
  salt.state:
    - tgt: '*'
    - sls:
      - virl.basics
