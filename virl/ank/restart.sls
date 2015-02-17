ank-restart:
  cmd.run:
    - name: |
        service virl-vis-mux restart
        service virl-vis-processor restart
        service virl-vis-webserver  restart
        service ank-cisco-webserver restart
        
