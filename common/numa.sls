{% set ksm = salt['pillar.get']('virl:numa_balancing', salt['grains.get']('numa_balancing', false)) %}

/proc/sys/kernel/numa_balancing:
  cmd.run:
    - name: '/sbin/sysctl kernel.numa_balancing=0'
    - unless:
      - 'grep -q 0 /proc/sys/kernel/numa_balancing'

numa no balance:
  file.managed:
    - name: /etc/sysctl.d/10-numa-balancing.conf
    - contents: |
        kernel.numa_balancing = 0
