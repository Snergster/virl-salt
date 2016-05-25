
cloud_init disabled:
  service.disabled:
    - name: 'cloud-init'

cloud_init_nonet disabled:
  service.disabled:
    - name: 'cloud-init-nonet'
