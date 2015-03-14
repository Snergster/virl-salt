libgit2 prereqs:
  pkg.installed:
    - pkgs:
      - cmake
      - python-dev
      - libffi-dev


libgit2 pull:
  archive.extracted:
    - name: /tmp/
    - source: http://github.com/libgit2/libgit2/archive/v0.22.0.tar.gz
    - source_hash: md5=a8c689d4887cc085295dcf43c46f5f1f
    - archive_format: tar
    - if_missing: /tmp/libgit2-0.22.0

cmake libgit2:
  cmd.run:
    - cwd: /tmp/libgit2-0.22.0
    - require:
      - pkg: libgit2 prereqs
      - archive: libgit2 pull
    - names:
      - cmake .
      - make
      - make install
      - ldconfig


pygit2 install:
  pip.installed:
    - name: pygit2
