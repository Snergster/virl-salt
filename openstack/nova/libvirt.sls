
/srv/salt/openstack/nova/patch/driver.diff:
  file.managed:
    - makedirs: True
    - file_mode: 755
    - contents: |
        --- driver.py	2014-07-10 13:22:21.000000000 +0000
        +++ driver.py	2015-02-10 22:26:30.465829748 +0000
        @@ -56,7 +56,6 @@
         from eventlet import greenthread
         from eventlet import patcher
         from eventlet import tpool
        -from eventlet import util as eventlet_util
         from lxml import etree
         from oslo.config import cfg

        @@ -622,12 +621,10 @@
                 except (ImportError, NotImplementedError):
                     # This is Windows compatibility -- use a socket instead
                     #  of a pipe because pipes don't really exist on Windows.
        -            sock = eventlet_util.__original_socket__(socket.AF_INET,
        -                                                     socket.SOCK_STREAM)
        +            sock = native_socket.socket(socket.AF_INET,socket.SOCK_STREAM)
                     sock.bind(('localhost', 0))
                     sock.listen(50)
        -            csock = eventlet_util.__original_socket__(socket.AF_INET,
        -                                                      socket.SOCK_STREAM)
        +            csock = native_socket.socket(socket.AF_INET,socket.SOCK_STREAM)
                     csock.connect(('localhost', sock.getsockname()[1]))
                     nsock, addr = sock.accept()
                     self._event_notify_send = nsock.makefile('wb', 0)

/usr/lib/python2.7/dist-packages/nova/virt/libvirt/driver.py:
  file.patch:
    - source: file:///srv/salt/openstack/nova/patch/driver.diff
    - hash: md5=7163850e833c811470fc1f2d46fbb5ea
  cmd.wait:
    - names:
      - python -m compileall /usr/lib/python2.7/dist-packages/nova/virl/libvirt/driver.py
    - watch:
      - file: /usr/lib/python2.7/dist-packages/nova/virt/libvirt/driver.py
    - require:
      - file: /srv/salt/openstack/nova/patch/driver.diff
