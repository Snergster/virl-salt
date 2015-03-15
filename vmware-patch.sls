rasa patches:
  git.latest:
    - name: https://github.com/rasa/vmware-tools-patches.git
    - target: /tmp/vmware-tools-patches
  cmd.run:
    - cwd: /tmp/vmware-tools-patches
    - name:
      - ./download-tools.sh 7.1.1

untar and patch:
  cmd.run:
    - cwd: /tmp/vmware-tools-patches
    - name: ./untar-and-patch.sh
    - require:
      - git: rasa patches

compile with patches:
  cmd.run:
    - cwd: /tmp/vmware-tools-patches
    - name: ./compile.sh
    - require:
      - cmd: untar and patch

vmware-tools-patches cleanup:
  file.absent:
    - name: /tmp/vmware-tools-patches
    - require:
      - cmd: compile with patches
