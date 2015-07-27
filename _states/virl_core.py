"""
VIRL-CORE salt state module.

Place this file on the minion under /srv/salt/_states/
and load it with: `sudo salt-call --local saltutil.sync_states`

To apply an SLS file, place it into /srv/salt/ then call:
`sudo salt-call --local state.sls <filename>`

An example SLS:

.. code-block:: yaml

    proj123:
      virl_core.project_present:
        - description: First project
        - expires: 2015-09-30 23:59
        - quota_instances: 50
        - quota_ram: 256000
        - quota_vcpus: 100

    proj123 main user:
      virl_core.user_present:
        - name: proj123
        - password: secret
        - project: proj123
        - role: admin
        - require:
          - virl_core: proj123

    proj123-user:
      virl_core.user_present:
        - password: secret
        - project: proj123
        - role: _member_
        - enabled: False
        - require:
          - virl_core: proj123

    testing:
      virl_core.project_absent:
        - clear_openstack: True
"""


def __virtual__():
    """Return the name of this state module"""
    # return False if should not be loaded
    return 'virl_core'


def __get_function(name):
    """Get a function of the virl_core module"""
    prefix = 'virl_core.'
    return __salt__[prefix + name]


def project_present(name, **kwargs):
    """Ensure that the UWM project `name` and its main user exist with the
    specified properties

    """
    ret = {'name': name,
           'result': True,
           'changes': {},
           'comment': ''}

    try:
        project = __get_function('project_get')(name)

        main_user = None
        if project and name in project['users']:
            main_user = __get_function('user_get')(name)

        result = __get_function('project_present')(name=name, **kwargs)

    except Exception as exc:
        ret['result'] = False
        ret['comment'] = str(exc)
    else:
        ret['changes']['project'] = {'old': project,
                                     'new': result['project']}
        ret['changes']['main-user'] = {'old': main_user,
                                       'new': result['main-user']}
        ret['comment'] = result['comment']

    return ret


def project_absent(name, clear_openstack=False):
    """Ensure that there's no project `name` in UWM. If `clear_openstack` is
    True, will also delete OpenStack tenants not known to UWM.

    """
    ret = {'name': name,
           'result': True,
           'changes': {},
           'comment': ''}

    try:
        fun = __get_function('project_absent')
        result = fun(name, clear_openstack=clear_openstack)

    except Exception as exc:
        ret['result'] = False
        ret['comment'] = str(exc)
    else:
        project = result['project']
        del_users = result.get('deleted-users') or []
        tenant = result.get('tenant')
        if project is not None:
            ret['changes']['project'] = {'old': project, 'new': None}
            all_users = project['users']
            users_left = list(set(all_users) - set(del_users))
            ret['changes']['project-users'] = {'old': all_users,
                                               'new': users_left}
        elif tenant is not None:
            ret['changes']['tenant'] = {'old': tenant, 'new': None}
        ret['comment'] = result['comment']

    return ret


def user_present(name, password, project, role, **kwargs):
    """Ensure that the UWM user `name` exists with the specified properties"""
    ret = {'name': name,
           'result': True,
           'changes': {},
           'comment': ''}

    try:
        user = __get_function('user_get')(name)
        result = __get_function('user_present')(name=name, password=password,
                                                project=project, role=role,
                                                **kwargs)
    except Exception as exc:
        ret['result'] = False
        ret['comment'] = str(exc)
    else:
        ret['changes']['user'] = {'old': user,
                                  'new': result['user']}
        ret['comment'] = result['comment']

    return ret


def user_absent(name, clear_openstack=False):
    """Ensure that there's no user `name` in UWM. If `clear_openstack` is
    True, will also delete OpenStack users not known to UWM.

    """
    ret = {'name': name,
           'result': True,
           'changes': {},
           'comment': ''}

    try:
        fun = __get_function('user_absent')
        result = fun(name, clear_openstack=clear_openstack)

    except Exception as exc:
        ret['result'] = False
        ret['comment'] = str(exc)
    else:
        user = result['user']
        os_user = result.get('os-user')
        if user is not None:
            ret['changes']['user'] = {'old': user, 'new': None}
        elif os_user is not None:
            ret['changes']['os_user'] = {'old': os_user, 'new': None}
        ret['comment'] = result['comment']

    return ret


def lxc_image_present(name, subtype, version, release=None):
    """Ensure that the UWM image `name` exists."""
    name = '%s-%s' % (subtype, version)
    ret = {
        'name': name,
        'result': False,
        'changes': {},
        'comment': '',
    }

    try:
        image = __get_function('lxc_image_show')(name=name)
        import logging
        log = logging.getLogger(__name__)
        log.debug(image)
        if 'name' in image and image['name'] == name:
            __get_function('lxc_image_delete')(name=name)
        else:
            image = None
        result = __get_function('lxc_image_create')(subtype, version, release)
    except Exception as exc:
        ret['comment'] = str(exc)
    else:
        ret['result'] = True
        ret['changes']['image'] = {'old': image, 'new': result['lxc-image']}
        ret['comment'] = 'Image %s was successfully added' % name

    return ret


def lxc_image_absent(name, subtype, version):
    """Ensure that there's no image `name` in UWM lxc images."""
    name = '%s-%s' % (subtype, version)
    ret = {
        'name': name,
        'result': False,
        'changes': {},
        'comment': '',
    }

    try:
        image = __get_function('lxc_image_show')(name=name)
        if 'name' in image and image['name'] == name:
            result = __get_function('lxc_image_delete')(name=name)
    except Exception as exc:
        ret['comment'] = str(exc)
    else:
        image = result['image']
        if image is not None:
            ret['changes']['image'] = {'old': image, 'new': None}
        ret['result'] = True
        ret['comment'] = 'Image %s was successfully deleted' % name

    return ret
