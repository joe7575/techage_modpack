#!/usr/bin/env python
import os

spath = "./"
n = len(spath)

for root, dirs, files in os.walk(spath):
    offs = root[n:]
    for fname in files:
        name, ext = os.path.splitext(fname)
        if ext == ".lua":
            src = os.path.join(spath, offs, fname)
            lOut = []
            changed = False
            for line in open(src, "rt").readlines():
                line2 = line.rstrip()
                if len(line2) != len(line) - 1:
                    changed = True
                lOut.append(line2)
            if changed:
                print("%s changed" % src)
                text = "\n".join(lOut) + "\n"
                open(src, "wt").write(text)
            
            
            
