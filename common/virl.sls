mypkgs:
  pkg.installed:
    - skip_verify: True
    - refresh: False
    - pkgs:
      - build-essential
      - python-dev
      - python-dateutil
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
