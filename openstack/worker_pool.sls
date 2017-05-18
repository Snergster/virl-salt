{% from "virl.jinja" import virl with context %}
{% from "openstack/worker_pool.jinja" import worker_count, db_pool %}


my.cnf template:
  file.managed:
    - name: /etc/mysql/my.cnf
    - source: salt://openstack/mysql/files/mitaka.my.cnf
    - template: jinja
    - makedirs: True


/etc/nova/nova.conf:
  file.managed:
    - mode: 755
    - template: jinja
    - source: "salt://openstack/nova/files/mitaka.nova.conf"


/etc/neutron/neutron.conf:
  file.managed:
    - template: jinja
    - makedirs: True
    - mode: 755
    - source: "salt://openstack/neutron/files/mitaka.neutron.conf"


/etc/keystone/keystone.conf:
  file.managed:
    - source: "salt://openstack/keystone/files/mitaka.keystone.conf.jinja"
    - template: jinja

/etc/apache2/sites-available/wsgi-keystone.conf:
  file.managed:
    - source: "salt://openstack/keystone/files/wsgi-keystone.conf"
    - template: jinja
    - mode: 0644


glance-api-workers:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'DEFAULT'
    - parameter: 'workers'
    - value: '{{ worker_count('glance-api') }}'

glance-reg-workers:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'DEFAULT'
    - parameter: 'workers'
    - value: '{{ worker_count('glance-registry') }}'


glance-api-dbpool-size:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'database'
    - parameter: 'max_pool_size'
    - value: '{{ db_pool.max_size }}'

glance-reg-dbpool-size:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'database'
    - parameter: 'max_pool_size'
    - value: '{{ db_pool.max_size }}'


glance-api-dbpool-overflow:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'database'
    - parameter: 'max_overflow'
    - value: '{{ db_pool.overflow }}'

glance-reg-dbpool-overflow:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'database'
    - parameter: 'max_overflow'
    - value: '{{ db_pool.overflow }}'


glance-api-dbpool-idle:
  openstack_config.present:
    - filename: /etc/glance/glance-api.conf
    - onlyif: test -e /etc/glance/glance-api.conf
    - section: 'database'
    - parameter: 'idle_timeout'
    - value: '{{ db_pool.idle_sec }}'

glance-reg-dbpool-idle:
  openstack_config.present:
    - filename: /etc/glance/glance-registry.conf
    - onlyif: test -e /etc/glance/glance-registry.conf
    - section: 'database'
    - parameter: 'idle_timeout'
    - value: '{{ db_pool.idle_sec }}'

{% if virl.cinder_enabled %}
/etc/cinder/cinder.conf:
  file.managed:
    - mode: 755
    - template: jinja
    - source: "salt://openstack/cinder/files/mitaka.cinder.conf"
{% endif %}

restart-mysql:
  cmd.run:
    - order: last
    - name: |
        service mysql restart
        service apache2 restart
        service nova-api restart
        service nova-scheduler restart
        service nova-conductor restart
        service neutron-server restart
        service glance-api restart
        service glance-registry restart
{% if virl.cinder_enabled %}
        service cinder-api restart
{% endif %}
