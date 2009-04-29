#!/usr/bin/python

import sys
import memcache
from optparse import OptionParser

stats = {'total_items': 0, 'bytes_written': 0, 'uptime': 0, 'bytes': 0,
         'cmd_get': 0, 'curr_items': 0, 'curr_connections': 0, 'connection_structures': 0,
         'limit_maxbytes': 0, 'rusage_user': 0.0, 'total_connections': 0, 'cmd_set': 0,
         'time': 0, 'get_misses': 0, 'bytes_read': 0, 'rusage_system': 0.0, 'get_hits': 0}

parser = OptionParser(usage="usage: %prog [-h] [-p PORT] HOSTNAME1 HOSTNAME2 ...\nTotals will be returned for multiple HOSTNAME arguments.")
parser.set_defaults(port = "11211")
parser.add_option("-p", "--port", dest="port", metavar="PORT",
                  help="default memcached port [default: 11211]")
(options, args) = parser.parse_args()

hosts = []
if (args):
    for host in args:
        hosts.append("%s:%s" % (host, options.port));
else:
    parser.error("At least one HOSTNAME is required.")
    sys.exit(1)

mc = memcache.Client(hosts, debug=0)
mem_stats = mc.get_stats()

if (not mem_stats):
        sys.exit()

if (len(mem_stats) > 1):
    for mstat in mem_stats:
        for key, val in stats.iteritems():
            if (key == 'rusage_user' or key == 'rusage_system'):
                stats[key] += float(mstat[1][key])
            else:
                stats[key] += int(mstat[1][key])

else:
    mstat = mem_stats[0][1];
    for key, val in stats.iteritems():
        if (key == 'rusage_user' or key == 'rusage_system'):
            stats[key] = float(mstat[key])
        else:
            stats[key] = int(mstat[key])

for stat, count in stats.iteritems():
    print "%s:%s\n" % (stat, count),
