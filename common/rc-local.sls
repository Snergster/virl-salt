rclocal replace buckets:
  file.replace:
    - name: /etc/rc.local
    - pattern: '# By default this script does nothing.'
    - repl: |
          # VIRL use. Please dont replace or alter the blocks below
          # 001s Cinder
          # 001e end
          # 002s v6off
          # 002e end
          # 003s start
          # 003e end
          # 004s start
          # 004e end
          # 005s start
          # 005e end
