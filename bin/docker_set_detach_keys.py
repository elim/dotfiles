#!/usr/bin/python

import errno
import json
import os

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

config_path = os.path.expanduser('~/.docker/config.json')

if os.path.exists(config_path):
    data = open(config_path, 'r')
    config_dict = json.load(data)
else:
    mkdir_p(os.path.dirname(config_path))
    config_dict = dict()

config_dict['detachKeys'] = 'ctrl-q,ctrl-q'

f = open(config_path, 'w')

json.dump(config_dict, f,
          ensure_ascii=False,
          indent=2,
          sort_keys=True, separators=(',', ': '))
