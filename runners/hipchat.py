import salt.client
opts = salt.config.minion_config('/etc/salt/minion')
opts.update({'file_client': 'local'})
caller = salt.client.Caller(mopts=opts)
def send_message(message,room='1332718',name='salt event'):
 caller.sminion.functions['hipchat.send_message'](room_id=(room),message=(message),from_name=(name))
