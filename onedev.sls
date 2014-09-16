
devops copy:
  file.recurse:
    - name: /var/cache/virl/devops
    - file_mode: 755
    - dir_mode: 755
    - source: "salt://images/devops-setup"

devops install:
    - cmd.run:
      - cwd: /var/cache/virl/devops
      - name: './devops_installer.sh -default -a'
      - watch:
        - file: devops copy
