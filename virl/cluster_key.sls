virl_ssh_key to grains:
  cmd.run:
    - name: /usr/local/bin/ssh_to_grain
    - require:
      - file: foobar
  file.managed:
    - name: /usr/local/bin/ssh_to_grain
    - mode: 0755
    - contents:  |
            #!/bin/bash
            value=`cat ~virl/.ssh/id_rsa.pub`
            salt-call --local grains.setval  virl_ssh_key "$value"


