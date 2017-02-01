import fcntl
import json
import socket
import struct
from operator import itemgetter

import redis
from lxml import etree
from oslo_config import cfg

CONF = cfg.CONF
CONF.import_group('serial_console', 'nova.console.serial')


class RedisUnavailable(Exception):
    pass


def push_node_info(sim_id, node_id, user_id, host, ports):
    port_0, port_1, port_2, port_3 = ports
    redis_host = CONF.serial_console.redis_hostname
    redis_port = CONF.serial_console.redis_port
    redis_instance = redis.StrictRedis(redis_host, redis_port)
    pipe = redis_instance.pipeline()
    d = {
        "user_id": user_id,
        "sim_id": sim_id,
        "node_id": node_id,
        "host": host,
        "port_0": port_0,
        "port_1": port_1,
        "port_2": port_2,
        "port_3": port_3
    }
    json_payload = json.dumps(d)
    pipe.lpush("node_info", json_payload)
    try:
        pipe.execute()
    except Exception as E:
        raise RedisUnavailable("Could not contact redis at "
                               "{}:{}.\nCause: {}".format(
                redis_host, redis_port, E.message))


def parse_serial_ports(xml):
    ports = [None] * 4
    try:
        root = etree.fromstring(xml)
        tree = etree.ElementTree(root)
        serials = tree.findall("//serial/source/[@service]")
        for index, port in enumerate(serials):
            ports[index] = int(port.get("service"))
        return ports
    except Exception as E:
        return [None] * 4


def local_if_ip():
    """Return local main public interface, its IP address

    It returns the IP address of the interface with the default
    route. If there are multiple, the one with the smallest metric is selected.

    """
    with open('/proc/net/route') as fp:
        route_table = map(lambda line: line.strip().split('\t'),
                          fp.readlines()[1:])

    IFNAME, DST, MASK, METRIC, DEFAULT = 0, 1, 7, 6, '00000000'

    def is_default(route):
        return route[DST] == DEFAULT and route[MASK] == DEFAULT

    default_route = sorted(filter(is_default, route_table),
                           key=itemgetter(METRIC))
    if len(default_route) == 0:
        interface = 'lo'
    else:
        interface = default_route[0][IFNAME]

    ip = interface_ip(interface=interface)

    return interface, ip


def interface_ip(interface):
    """Return IP address of a host interface"""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sockfd = sock.fileno()

    SIOCGIFADDR = 0x8915
    pack = '16sH14s'

    ifreq = struct.pack(pack, str(interface), socket.AF_INET, '\x00' * 14)
    resip = fcntl.ioctl(sockfd, SIOCGIFADDR, ifreq)

    return socket.inet_ntoa(resip[-12:-8])


def local_ip():
    _, ip = local_if_ip()
    return ip
