# Copyright 2012 OpenStack Foundation
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import webob

from nova.api.openstack import common
from nova.api.openstack.compute.schemas import remote_consoles
from nova.api.openstack import extensions
from nova.api.openstack import wsgi
from nova.api import validation
from nova import compute
from nova import exception


ALIAS = "os-remote-consoles"
authorize = extensions.os_compute_authorizer(ALIAS)


class RemoteConsolesController(wsgi.Controller):
    def __init__(self, *args, **kwargs):
        self.compute_api = compute.API(skip_policy_check=True)
        self.handlers = {'vnc': self.compute_api.get_vnc_console,
                         'spice': self.compute_api.get_spice_console,
                         'rdp': self.compute_api.get_rdp_console,
                         'serial': self.compute_api.get_serial_console,
                         'mks': self.compute_api.get_mks_console}
        super(RemoteConsolesController, self).__init__(*args, **kwargs)

    @wsgi.Controller.api_version("2.1", "2.5")
    @extensions.expected_errors((400, 404, 409, 501))
    @wsgi.action('os-getVNCConsole')
    @validation.schema(remote_consoles.get_vnc_console)
    def get_vnc_console(self, req, id, body):
        """Get text console output."""
        context = req.environ['nova.context']
        authorize(context)

        # If type is not supplied or unknown, get_vnc_console below will cope
        console_type = body['os-getVNCConsole'].get('type')

        try:
            instance = common.get_instance(self.compute_api, context, id)
            output = self.compute_api.get_vnc_console(context,
                                                      instance,
                                                      console_type)
        except exception.ConsoleTypeUnavailable as e:
            raise webob.exc.HTTPBadRequest(explanation=e.format_message())
        except (exception.InstanceUnknownCell,
                     exception.InstanceNotFound) as e:
            raise webob.exc.HTTPNotFound(explanation=e.format_message())
        except exception.InstanceNotReady as e:
            raise webob.exc.HTTPConflict(explanation=e.format_message())
        except NotImplementedError:
            common.raise_feature_not_supported()

        return {'console': {'type': console_type, 'url': output['url']}}

    @wsgi.Controller.api_version("2.1", "2.5")
    @extensions.expected_errors((400, 404, 409, 501))
    @wsgi.action('os-getSPICEConsole')
    @validation.schema(remote_consoles.get_spice_console)
    def get_spice_console(self, req, id, body):
        """Get text console output."""
        context = req.environ['nova.context']
        authorize(context)

        # If type is not supplied or unknown, get_spice_console below will cope
        console_type = body['os-getSPICEConsole'].get('type')

        try:
            instance = common.get_instance(self.compute_api, context, id)
            output = self.compute_api.get_spice_console(context,
                                                        instance,
                                                        console_type)
        except exception.ConsoleTypeUnavailable as e:
            raise webob.exc.HTTPBadRequest(explanation=e.format_message())
        except (exception.InstanceUnknownCell,
                     exception.InstanceNotFound) as e:
            raise webob.exc.HTTPNotFound(explanation=e.format_message())
        except exception.InstanceNotReady as e:
            raise webob.exc.HTTPConflict(explanation=e.format_message())
        except NotImplementedError:
            common.raise_feature_not_supported()

        return {'console': {'type': console_type, 'url': output['url']}}

    @wsgi.Controller.api_version("2.1", "2.5")
    @extensions.expected_errors((400, 404, 409, 501))
    @wsgi.action('os-getRDPConsole')
    @validation.schema(remote_consoles.get_rdp_console)
    def get_rdp_console(self, req, id, body):
        """Get text console output."""
        context = req.environ['nova.context']
        authorize(context)

        # If type is not supplied or unknown, get_rdp_console below will cope
        console_type = body['os-getRDPConsole'].get('type')

        instance = common.get_instance(self.compute_api, context, id)
        try:
            # NOTE(mikal): get_rdp_console() can raise InstanceNotFound, so
            # we still need to catch it here.
            output = self.compute_api.get_rdp_console(context,
                                                      instance,
                                                      console_type)
        except exception.ConsoleTypeUnavailable as e:
            raise webob.exc.HTTPBadRequest(explanation=e.format_message())
        except (exception.InstanceUnknownCell,
                     exception.InstanceNotFound) as e:
            raise webob.exc.HTTPNotFound(explanation=e.format_message())
        except exception.InstanceNotReady as e:
            raise webob.exc.HTTPConflict(explanation=e.format_message())
        except NotImplementedError:
            common.raise_feature_not_supported()

        return {'console': {'type': console_type, 'url': output['url']}}

    @wsgi.Controller.api_version("2.1", "2.5")
    @extensions.expected_errors((400, 404, 409, 501))
    @wsgi.action('os-getSerialConsole')
    @validation.schema(remote_consoles.get_serial_console)
    def get_serial_console(self, req, id, body):
        """Get connection to a serial console."""
        context = req.environ['nova.context']
        authorize(context)

        # If type is not supplied or unknown get_serial_console below will cope
        key = 'os-getSerialConsole'
        if key not in body:
            key = 'os-getSerialPort'
        console_type = body[key].get('type', 'serial')
        console_index = int(body[key].get('serial_port', 0))
        try:
            instance = common.get_instance(self.compute_api, context, id)
            output = self.compute_api.get_serial_console(context,
                                                         instance,
                                                         console_type,
                                                         index=console_index)
        except (exception.InstanceUnknownCell,
                     exception.InstanceNotFound) as e:
            raise webob.exc.HTTPNotFound(explanation=e.format_message())
        except exception.InstanceNotReady as e:
            raise webob.exc.HTTPConflict(explanation=e.format_message())
        except (exception.ConsoleTypeUnavailable,
                exception.ImageSerialPortNumberInvalid,
                exception.ImageSerialPortNumberExceedFlavorValue,
                exception.SocketPortRangeExhaustedException) as e:
            raise webob.exc.HTTPBadRequest(explanation=e.format_message())
        except NotImplementedError:
            common.raise_feature_not_supported()

        return {'console': {'type': console_type, 'url': output['url']}}

    @wsgi.Controller.api_version("2.1", "2.5")
    @extensions.expected_errors((400, 404, 409, 501))
    @wsgi.action('os-getSerialPort')
    @validation.schema(remote_consoles.get_serial_port)
    def get_serial_port(self, req, id, body):
        """Get connection to a serial console."""
        body['os-getSerialConsole'] = body['os-getSerialPort']
        del body['os-getSerialPort']
        return self.get_serial_console(req=req, id=id, body=body)

    @wsgi.Controller.api_version("2.6")
    @extensions.expected_errors((400, 404, 409, 501))
    @validation.schema(remote_consoles.create_v26, "2.6", "2.7")
    @validation.schema(remote_consoles.create_v28, "2.8")
    def create(self, req, server_id, body):
        context = req.environ['nova.context']
        authorize(context)
        instance = common.get_instance(self.compute_api, context, server_id)
        protocol = body['remote_console']['protocol']
        console_type = body['remote_console']['type']
        try:
            handler = self.handlers.get(protocol)
            output = handler(context, instance, console_type)
            return {'remote_console': {'protocol': protocol,
                                       'type': console_type,
                                       'url': output['url']}}

        except exception.InstanceNotFound as e:
            raise webob.exc.HTTPNotFound(explanation=e.format_message())
        except exception.InstanceNotReady as e:
            raise webob.exc.HTTPConflict(explanation=e.format_message())
        except (exception.ConsoleTypeInvalid,
                exception.ConsoleTypeUnavailable,
                exception.ImageSerialPortNumberInvalid,
                exception.ImageSerialPortNumberExceedFlavorValue,
                exception.SocketPortRangeExhaustedException) as e:
            raise webob.exc.HTTPBadRequest(explanation=e.format_message())
        except NotImplementedError:
            common.raise_feature_not_supported()


class RemoteConsoles(extensions.V21APIExtensionBase):
    """Interactive Console support."""
    name = "Consoles"
    alias = ALIAS
    version = 1

    def get_controller_extensions(self):
        controller = RemoteConsolesController()
        extension = extensions.ControllerExtension(self, 'servers', controller)
        return [extension]

    def get_resources(self):
        parent = {'member_name': 'server',
                  'collection_name': 'servers'}
        resources = [
            extensions.ResourceExtension(
                'remote-consoles', RemoteConsolesController(), parent=parent,
                member_name='remote-console')]
        return resources
