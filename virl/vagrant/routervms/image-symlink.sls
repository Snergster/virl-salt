
vagrant symlink:
  file.symlink:
    - name: /srv/salt/images/salt
    - makedirs: true
    - target: /vagrant/images
