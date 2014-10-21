install basics:
  salt.state:
    - tgt: 'ejkbootie.virl.qa'
    - sls:
      - virl.virluser
      - common.virl
      - virl.basics

get grains in place:
  salt.function:
    - tgt: 'ejkbootie.virl.qa'
    - name: cmd.run
    - arg:
      - /usr/local/bin/vinstall salt

host basics:
  salt.state:
    - tgt: 'ejkbootie.virl.qa'
    - sls:
      - virl.basics
