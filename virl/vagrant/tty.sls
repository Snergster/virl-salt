
/root/.profile:
  file.replace:
    - pattern: ^tty -s$
    - repl: tty -s && mesn n
