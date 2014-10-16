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
