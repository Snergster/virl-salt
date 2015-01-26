"""
VIRL-CORE salt execution module.

Provides functions for STD and OpenStack user and project management.
Uses virl_uwm_client and virl_openstack_client commands.

To use this module on a minion::

  - place it into /srv/salt/_modules/
    and call: `sudo salt-call --local saltutil.sync_modules`
    then: `sudo salt-call --local virl_core.<function> <parameters>`

  - or directly pass the module's location with the -m parameter to salt-call:
    `sudo salt-call --local -m <path> virl_core.<function> <parameters>`
"""


import simplejson
import subprocess
from salt.exceptions import CommandExecutionError


# Default parameter values
VIRL_NEEDS_SUDO = True
uwm_username = 'uwmadmin'
uwmadmin_password = 'password'
uwm_url = 'http://localhost:19400'
os_username = 'admin'
password = 'password'
OS_TENANT = 'admin'
OS_AUTH_URL = 'http://localhost:5000/v2.0'


def __virtual__():
    """Return the name of this execution module"""
    # return False if should not be loaded
    return 'virl_core'


def __get_config(key, default=None):
    """Get salt configuration using config.get, defaulting to `default`"""
    prefix = 'virl_core.'
    return __salt__['grains.get'](key, default)


class VirlCommandExecutionError(CommandExecutionError):

    def __init__(self, output, exitcode=None):
        super(VirlCommandExecutionError, self).__init__(output, exitcode)
        self.output = output
        self.exitcode = exitcode


def __command(command, subcommand, args=(), kwargs={}, subargs=(),
              subkwargs={}):
    """Always returns a dict parsed from the output JSON, or
    raises a `VirlCommandExecutionError` with stdout and stderr and exit code.

    """
    cmd = []
    if __get_config('virl_needs_sudo', VIRL_NEEDS_SUDO):
        cmd.append('sudo')
    cmd.append(command)
    cmd.extend(args)
    for item in kwargs.iteritems():
        cmd.extend(item)
    cmd.append(subcommand)
    cmd.extend(subargs)
    for item in subkwargs.iteritems():
        cmd.extend(item)
    cmd = map(str, cmd)

    prc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = prc.communicate()
    code = prc.returncode

    if prc.returncode == 0:
        result = out.strip() or '{}'
        try:
            result = simplejson.loads(result)
            return result
        except Exception:
            raise VirlCommandExecutionError(out, code)
    else:
        raise VirlCommandExecutionError(out + err, code)


def __uwm_client(command, args=(), kwargs={}):
    """Call a virl_uwm_client command"""
    return __command(command='virl_uwm_client',
                     args=('--quiet', '--json'),
                     kwargs={'-l': __get_config('uwm_url', uwm_url),
                             '-u': __get_config('uwm_username', uwm_username),
                             '-p': __get_config('uwmadmin_password', uwmadmin_password)},
                     subcommand=command,
                     subargs=args,
                     subkwargs=kwargs)


def __os_client(command, args=(), kwargs={}):
    """Call a virl_openstack_client command"""
    return __command(command='virl_openstack_client',
                     args=('--quiet', '--json'),
                     kwargs={'-A': __get_config('os_auth_url', OS_AUTH_URL),
                             '-U': __get_config('os_username', os_username),
                             '-P': __get_config('password', password),
                             '-T': __get_config('os_tenant', OS_TENANT)},
                     subcommand=command,
                     subargs=args,
                     subkwargs=kwargs)


def project_list():
    """Get all UWM projects.

    :returns: list of dict

    """
    result = __uwm_client('project-info')
    return result['projects']


def user_list():
    """Get all UWM users.

    :returns: list of dict

    """
    result = __uwm_client('user-info')
    return result['users']


def project_get(name):
    """Get a UWM project.

    :returns: dict or None

    """
    try:
        result = __uwm_client('project-info', kwargs={'-n': name})
        return result['project']
    except VirlCommandExecutionError as exc:
        if '404' in exc.output:
            return None
        else:
            raise


def _tenant_get(name):
    """Get an OpenStack project, i.e. tenant.

    :returns: dict or None

    """
    try:
        result = __os_client('identity-tenant-info',
                             kwargs={'-f': 'name=%s' % name})
        if result:
            return result
        else:
            return None
    except VirlCommandExecutionError as exc:
        if '404' in exc.output:
            return None
        else:
            raise


def user_get(name):
    """Get a UWM user.

    :returns: dict or None

    """
    try:
        result = __uwm_client('user-info', kwargs={'-n': name})
        return result['user']
    except VirlCommandExecutionError as exc:
        if '404' in exc.output:
            return None
        else:
            raise


def _os_user_get(name):
    """Get an OpenStack user.

    :returns: dict or None

    """
    try:
        result = __os_client('identity-user-info',
                             kwargs={'-f': 'name=%s' % name})
        if result:
            return result
        else:
            return None
    except VirlCommandExecutionError as exc:
        if '404' in exc.output:
            return None
        else:
            raise


def project_absent(name, clear_openstack=False):
    """Ensure that there's no project `name` in UWM. If `clear_openstack` is
    True, will also delete OpenStack tenants not known to UWM.

    :returns: dict with keys ('project', 'deleted-users', 'tenant', 'comment')

    """
    comment = 'Project did not exist'
    project = project_get(name)
    deleted_users = []
    tenant = _tenant_get(name)

    if project is not None:
        result = __uwm_client('project-delete', kwargs={'-n': name})
        if not result.get('deleted-project'):
            raise CommandExecutionError(str(result))
        deleted_users = result['deleted-users']
        comment = 'UWM project was deleted'

    elif tenant is not None:
        if not clear_openstack:
            raise CommandExecutionError('Project exists only in OpenStack, but'
                                        ' "clear_openstack" flag is not set')
        __os_client('identity-tenant-delete', kwargs={'-t': tenant['id']})
        comment = 'OpenStack tenant was deleted'

    return {'project': project,
            'deleted-users': deleted_users,
            'tenant': tenant,
            'comment': comment}


def user_absent(name, clear_openstack=False):
    """Ensure that there's no user `name` in UWM. If `clear_openstack` is
    True, will also delete OpenStack users not known to UWM.

    :returns: dict with keys ('user', 'os-user', 'comment')

    """
    comment = 'User did not exist'
    user = user_get(name)
    os_user = _os_user_get(name)

    if user is not None:
        __uwm_client('user-delete', kwargs={'-n': name})
        comment = 'UWM user was deleted'

    elif os_user is not None:
        if not clear_openstack:
            raise CommandExecutionError('User exists only in OpenStack, but'
                                        ' "clear_openstack" flag is not set')
        __os_client('identity-user-delete', kwargs={'-u': os_user['id']})
        comment = 'OpenStack user was deleted'

    return {'user': user,
            'os-user': os_user,
            'comment': comment}


def project_present(name, **kwargs):
    """Ensure that there's a UWM project with the specified properties.

    :returns: dict with keys ('project', 'main-user', 'comment')

    """
    props = {'name': name}
    for key in ('description', 'expires', 'enabled', 'user_password',
                'user_os_password', 'networks', 'quota_instances', 'quota_ram',
                'quota_vcpus'):
        if key in kwargs:
            json_key = key.replace('_', '-')
            props[json_key] = kwargs[key]
    data = simplejson.dumps({'projects': [props],
                             'users': []})

    results = __uwm_client('project-import',
                           args=('--update',),
                           kwargs={'--data': data})

    result = results['results'][0]
    if 'exception' in result:
        raise CommandExecutionError(result['exception'])

    return result


def user_present(name, password, project, role, **kwargs):
    """Ensure that there's a UWM user with the specified properties.

    :returns: dict with keys ('user', 'comment')

    """
    if project_get(project) is None:
        raise CommandExecutionError('Project does not exist')

    props = {'username': name,
             'password': password,
             'project': project,
             'role': role}
    for key in ('os_password', 'email', 'expires', 'enabled', 'endpoint',
                'ssh_public_key'):
        if key in kwargs:
            json_key = key.replace('_', '-')
            props[json_key] = kwargs[key]
    data = simplejson.dumps({'projects': [],
                             'users': [props]})

    results = __uwm_client('project-import',
                           args=('--update',),
                           kwargs={'--data': data})

    result = results['results'][0]
    if 'exception' in result:
        raise CommandExecutionError(result['exception'])

    return result
