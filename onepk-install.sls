/tmp/onePK-sdk-c-latest-lnx-x86_64.tar:
  file.managed:
    - order: 1
    - source: "salt://files/sdk/onePK-sdk-c-latest-lnx-x86_64.tar"
    - user: virl
    - group: virl

/tmp/onePK-sdk-java-latest-all.tar:
  file.managed:
    - order: 2
    - source: "salt://files/sdk/onePK-sdk-java-latest-all.tar"
    - user: virl
    - group: virl

/tmp/onePK-sdk-python-latest-all.tar.gz:
  file.managed:
    - order: 3
    - source: "salt://files/sdk/onePK-sdk-python-latest-all.tar.gz"
    - user: virl
    - group: virl

/home/virl/.onepk_sdk_installers:
  file.recurse:
    - order: 4
    - user: virl
    - group: virl
    - file_mode: 755
    - dir_mode: 755
    - source: "salt://files/.onepk_sdk_installers/"

onepk_sdk_installer:
  cmd.run:
    - order: 5
    - cwd: /home/virl/.onepk_sdk_installers
    - user: virl
    - group: virl
    - name: '/home/virl/.onepk_sdk_installers/onepk_sdk_installer.sh -u -m 3.2.1 -f'

onepk-eclipse:
  archive:
    - order: 6
    - extracted
    - name: /usr/local/bin/
    - archive_format: tar
    - tar_options: x
    - source: "salt://files/eclipse.tar"
    - if_missing: /usr/local/bin/eclipse/

/home/virl/Desktop/Eclipse.desktop:
  file.managed:
    - order: 7
    - makedirs: True
    - source: "salt://files/Eclipse.desktop"
    - user: virl
    - group: virl
    - file_mode: 755

