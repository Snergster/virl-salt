
/root/.profile:
  file.replace:
    - pattern: ^mesg n$
    - repl: tty -s && mesg n
