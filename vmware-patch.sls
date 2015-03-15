https://github.com/rasa/vmware-tools-patches.git:
  git.latest:
    - rev: develop
    - target: /tmp
  cmd.run:
    - cwd: /tmp/vmware-tools-patches
    - name:
      - download-tools.sh 7.1.1
      - untar-and-patch.sh
      - compile.sh
