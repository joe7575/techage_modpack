#!/usr/bin/env python2
# -*- coding: iso-8859-1 -*-

import os
import re
import sys

def grep(pattern, path='./', endings=['.lua']):
    """
    Search in all files with the ending 'endings' in the given 'path'
    for the given text 'pattern'.
    """
    lOut = []
    for dirpath, dirnames, filenames in os.walk(path):
        for name in filenames:
            _, ext = os.path.splitext(name)
            if ext in endings:
                filename = os.path.join(dirpath, name)
                i = 0
                ## line oriented approach
                for line in file(filename).readlines():
                    i = i + 1
                    match = re.search(pattern, line)    # search pattern in line
                    if match:
                        print filename + ' [' + str(i) + '] ' + line.strip()
    return lOut

if __name__ == '__main__':
    grep(sys.argv[1])
