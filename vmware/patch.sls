rasa patches:
  git.latest:
    - name: https://github.com/rasa/vmware-tools-patches.git
    - target: /tmp/vmware-tools-patches

uninstall tool:
  file.managed:
    - name : /usr/bin/vmware-uninstall-tools.pl
    - source: salt://vmware/files/vmware-uninstall-tools.pl

download tools:
  cmd.run:
    - cwd: /tmp/vmware-tools-patches
    - name: ./download-tools.sh 8.0.2
    - require:
      - git: rasa patches

untar and patch:
  cmd.run:
    - cwd: /tmp/vmware-tools-patches
    - name: ./untar-and-patch.sh
    - require:
      - cmd: download tools

compile with patches:
  cmd.run:
    - cwd: /tmp/vmware-tools-patches
    - name: ./compile.sh force-install
    - require:
      - cmd: untar and patch

vmware-tools-patches cleanup:
  file.absent:
    - name: /tmp/vmware-tools-patches
    - require:
      - cmd: compile with patches
