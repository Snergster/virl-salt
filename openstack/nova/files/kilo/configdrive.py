# Copyright 2012 Michael Still and Canonical Inc
# All Rights Reserved.
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

"""Config Drive v2 helper."""

import os
import shutil
import gzip
import cStringIO as StringIO

from oslo_config import cfg
from oslo_log import log as logging
from oslo_utils import strutils
from oslo_utils import units

from nova import exception
from nova.i18n import _LW
from nova.openstack.common import fileutils
from nova import utils
from nova import version

LOG = logging.getLogger(__name__)

configdrive_opts = [
    cfg.StrOpt('config_drive_format',
               default='iso9660',
               help='Config drive format. One of iso9660 (default) or vfat'),
    # force_config_drive is a string option, to allow for future behaviors
    #  (e.g. use config_drive based on image properties)
    cfg.StrOpt('force_config_drive',
               choices=('always', 'True', 'False'),
               help='Set to "always" to force injection to take place on a '
                    'config drive. NOTE: The "always" will be deprecated in '
                    'the Liberty release cycle.'),
    cfg.StrOpt('mkisofs_cmd',
               default='genisoimage',
               help='Name and optionally path of the tool used for '
                    'ISO image creation')
    ]

CONF = cfg.CONF
CONF.register_opts(configdrive_opts)

# Config drives are 64mb, if we can't size to the exact size of the data
CONFIGDRIVESIZE_BYTES = 64 * units.Mi


class ConfigDriveBuilder(object):
    """Build config drives, optionally as a context manager."""

    def __init__(self, disk_type, instance_md=None, files=None):
        # valid disk types:
        # cloud-init (default): an ISO or VFAT Openstack-style cloud-init FS
        # cloud-init-iso9660, cloud-init-vfat: as above but type specified
        #     rather than pulled from config
        # cdrom, disk: a raw, gzipped device image in file /__disk_image
        # iso9660, vfat: all injected files in whichever FS format

        self.device_type = None
        if CONF.force_config_drive == 'always':
            LOG.warning(_LW('The setting "always" will be deprecated in the '
                            'Liberty version. Please use "True" instead'))
        self.imagefile = None
        self.mdfiles = []

        if instance_md is not None:
            self.add_instance_metadata(instance_md)

        if disk_type in ['cloud-init', 'cloud-init-iso9660',
                         'cloud-init-vfat']:
            if instance_md is not None:
                self.add_instance_metadata(instance_md)
            if disk_type == 'cloud-init':
                self.fs_type = CONF.config_drive_format
            elif disk_type == 'cloud-init-vfat':
                self.fs_type = 'vfat'
            else:
                self.fs_type = 'iso9660'

        elif disk_type in ['vfat', 'iso9660']:
            if files is not None:
                self.add_raw_files(files)

            self.fs_type = disk_type

        elif disk_type in ['cdrom', 'disk']:
            gzip_image = ''
            if files is not None:
                for (idx, v) in enumerate(files):
                    (path, value) = v
                    if path == '/__config_drive_image__':
                        gzip_image = value
                        del files[idx]
                        break

            self.compressed_fs = gzip_image
            self.device_type = disk_type
            self.fs_type = None

        else:
            raise exception.ConfigDriveUnknownPropertyFormat(
                format=disk_type)

        LOG.debug("Config drive disk type: %s, fs type: %s"
                  % (disk_type, self.fs_type))

    def __enter__(self):
        return self

    def __exit__(self, exctype, excval, exctb):
        if exctype is not None:
            # NOTE(mikal): this means we're being cleaned up because an
            # exception was thrown. All bets are off now, and we should not
            # swallow the exception
            return False
        self.cleanup()

    def _add_file(self, basedir, path, data):
        filepath = os.path.join(basedir, path)
        dirname = os.path.dirname(filepath)
        fileutils.ensure_tree(dirname)
        with open(filepath, 'wb') as f:
            f.write(data)

    def add_instance_metadata(self, instance_md):
        for (path, data) in instance_md.metadata_for_config_drive():
            self.mdfiles.append((path, data))

    def add_raw_files(self, files):
        for (path, value) in files:
            # Create a root-based, normalised version of the path -
            # gets rid of '..'s and other dangers
            path = os.path.normpath(os.path.join("/", path))
            # Convert this to a relative path by removing the leading '/'
            path = path[1:]
            # Reuse mdfiles list to write the files at the correct time
            self.mdfiles.append((path, value))
            LOG.debug('Added %(filepath)s to config drive',
                      {'filepath': path})

    def _write_md_files(self, basedir):
        for data in self.mdfiles:
            self._add_file(basedir, data[0], data[1])

    def _make_iso9660(self, path, tmpdir):
        publisher = "%(product)s %(version)s" % {
            'product': version.product_string(),
            'version': version.version_string_with_package()
            }

        utils.execute(CONF.mkisofs_cmd,
                      '-o', path,
                      '-ldots',
                      '-allow-lowercase',
                      '-allow-multidot',
                      '-l',
                      '-publisher',
                      publisher,
                      '-quiet',
                      '-J',
                      '-r',
                      '-V', 'config-2',
                      tmpdir,
                      attempts=1,
                      run_as_root=False)

    def _make_vfat(self, path, tmpdir):
        # NOTE(mikal): This is a little horrible, but I couldn't find an
        # equivalent to genisoimage for vfat filesystems.
        with open(path, 'wb') as f:
            f.truncate(CONFIGDRIVESIZE_BYTES)

        utils.mkfs('vfat', path, label='config-2')

        with utils.tempdir() as mountdir:
            mounted = False
            try:
                _, err = utils.trycmd(
                    'mount', '-o', 'loop,uid=%d,gid=%d' % (os.getuid(),
                                                           os.getgid()),
                    path,
                    mountdir,
                    run_as_root=True)
                if err:
                    raise exception.ConfigDriveMountFailed(operation='mount',
                                                           error=err)
                mounted = True

                # NOTE(mikal): I can't just use shutils.copytree here,
                # because the destination directory already
                # exists. This is annoying.
                for ent in os.listdir(tmpdir):
                    src = os.path.join(tmpdir, ent)
                    if os.path.isfile(src):
                        shutil.copy(src, mountdir)
                    else:
                        shutil.copytree(src, os.path.join(mountdir, ent))

            finally:
                if mounted:
                    utils.execute('umount', mountdir, run_as_root=True)

    def make_drive(self, path):
        """Make the config drive.

        :param path: the path to place the config drive image at

        :raises ProcessExecuteError if a helper process has failed.
        """
        if self.fs_type is None:  # a raw image
            LOG.debug("Unpacking compressed config drive image")
            buffer = StringIO.StringIO(self.compressed_fs)
            with gzip.GzipFile(fileobj=buffer, mode='rb') \
                    as gbuffer:
                # TODO(ijw): danger of memory consumption
                decompressed = gbuffer.read()

                # write the contents as a local disk file
                with open(path, 'wb') as conf_drive:
                    conf_drive.write(decompressed)
            # device_type previously set

        elif self.fs_type == 'iso9660':
            with utils.tempdir() as tmpdir:
                self._write_md_files(tmpdir)
                self._make_iso9660(path, tmpdir)
            self.device_type = 'cdrom'
        elif self.fs_type == 'vfat':
            with utils.tempdir() as tmpdir:
                self._write_md_files(tmpdir)
                self._make_vfat(path, tmpdir)
            self.device_type = 'disk'
        else:
            raise exception.ConfigDriveUnknownFormatEx(
                format=self.fs_type)
        LOG.debug("Config drive device type: %s" % (self.device_type))

    def cleanup(self):
        if self.imagefile:
            fileutils.delete_if_exists(self.imagefile)

    def __repr__(self):
        return "<ConfigDriveBuilder: " + str(self.mdfiles) + ">"


def required_by(instance):

    image_prop = utils.instance_sys_meta(instance).get(
        utils.SM_IMAGE_PROP_PREFIX + 'img_config_drive', 'optional')
    if image_prop not in ['optional', 'mandatory']:
        LOG.warning(_LW('Image config drive option %(image_prop)s is invalid '
                        'and will be ignored'),
                    {'image_prop': image_prop},
                    instance=instance)

    return (instance.get('config_drive') or
            'always' == CONF.force_config_drive or
            strutils.bool_from_string(CONF.force_config_drive) or
            image_prop == 'mandatory'
            )


def update_instance(instance):
    """Update the instance config_drive setting if necessary

    The image or configuration file settings may override the default instance
    setting. In this case the instance needs to mirror the actual
    virtual machine configuration.
    """
    if not instance.config_drive and required_by(instance):
        instance.config_drive = True
