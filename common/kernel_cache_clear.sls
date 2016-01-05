kernel_clear_cache:
  file.managed:
    - name: /usr/local/bin/kernel_clear_cache
    - mode: 0755
    - contents:  |
        #!/bin/bash
        sync; sudo echo 3 > /proc/sys/vm/drop_caches


kernel cache clear:
  cmd.run:
    - name: /usr/local/bin/kernel_clear_cache

/usr/local/bin/kernel_clear_cache > /tmp/kernelclear:
  cron.present:
    - identifier: kernel cache clear
    - user: root
    - minute: 15,45
