# 
import os
from PIL import Image
import numpy as np
os.chdir(os.path.dirname(__file__))

ascii_code = 0
is_code = False
FONT_COLOR = 0x000000FF
BGND_COLOR = 0x00000000
WIDTH = 7
HEIGHT = 14

Data = np.zeros(WIDTH * HEIGHT * 4, dtype=np.uint8)

def add_row(data, index, row):
    for i in range(0, WIDTH):
        idx = ((index * WIDTH) + i) * 4
        if row & (1 << (7 - i)):
            data[idx+0] = FONT_COLOR >> 24
            data[idx+1] = FONT_COLOR >> 16
            data[idx+2] = FONT_COLOR >> 8
            data[idx+3] = FONT_COLOR >> 0
        else:
            data[idx:idx+4] = BGND_COLOR
    
for line in open('./Dina_r400-8.bdf'):
    words = line.split()
    if len(words) == 0:
        continue
    if words[0] == 'ENDCHAR':
        is_code = False
        if ascii_code >= 0x20 and ascii_code <= 0x7E:
            img = Image.frombuffer("RGBA", (WIDTH, HEIGHT), Data, "raw", "RGBA", 0, 1)
            img.save("lcdm%02X.png" % ascii_code)
        index = 0
        Data = np.zeros(WIDTH * HEIGHT * 4, dtype=np.uint8)
    elif is_code and len(words)== 1:
        add_row(Data, index, int(words[0], 16))
        index += 1
    elif words[0] == 'ENCODING':
        ascii_code = int(words[1])
    elif words[0] == 'BITMAP':
        is_code = True
        index = 0
        
