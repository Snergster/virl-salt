get_efibios:
  file.managed:
    - name: /usr/share/qemu/n9kbios.bin
    - makedirs: True
    - source:
      - salt://virl/files/n9kbios.bin
    - source_hash: 443c99c734736d6323f68b3f6c0df06f
