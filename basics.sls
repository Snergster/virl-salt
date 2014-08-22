squid-deb-proxy-client:
  pkg.installed:
    - skip_verify: True

mypkgs:
  pkg.installed:
    - skip_verify: True
    - refresh: False
    - pkgs:
      - build-essential
      - python-dev
      - git
      - ntp
      - debconf-utils
      - traceroute
      - dkms
      - kexec-tools
      - ntpdate
      - zile
      - curl
      - sshpass
      - emacs

/proc/sys/kernel/numa_balancing:
  file.managed:
    - content: 0
