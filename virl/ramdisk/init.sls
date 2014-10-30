/etc/fstab:
  file:
{% if ramdisk == True %}
    - append
    - text: 'ramdisk /var/lib/nova/instances tmpfs rw,relatime 0 0'
{% else %}
    - comment
    - name: /etc/fstab
    - regex: ^ramdisk
    - onlyif: "grep 'ramdisk' /etc/fstab"
{% endif %}
