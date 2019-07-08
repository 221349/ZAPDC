#!/usr/bin/env python3
# ycc.py

import numpy as np

class BT_601:
    # Kb, Kr for ITU-R BT.601
    Kb = 0.114
    Kr = 0.299

class BT_709:
    # Kb, Kr for ITU-R BT.709
    Kb = 0.0722
    Kr = 0.2126

def matrix_RGB2YCC(c):
    cr_c = -1/(2 * (1 - c.Kr))
    cb_c = -1/(2 * (1 - c.Kb))
    return [
        [c.Kr,              (1 - c.Kr - c.Kb),         c.Kb],
        [cb_c*c.Kr,         cb_c*(1 - c.Kr - c.Kb),    cb_c*(c.Kb - 1)],
        [cr_c*(c.Kr - 1),   cr_c*(1 - c.Kr - c.Kb),    cr_c*c.Kb]
        ]

def rgb2ycc(img, conversion):
    if(conversion == 'BT_709'):
        m = matrix_RGB2YCC(BT_709)
    else:
        m = matrix_RGB2YCC(BT_601)
    img_lx = len(img[0])
    img_ly = len(img)
    out = np.zeros((img_ly, img_lx, 3), 'float')
    for y in range(img_ly):
        for x in range(img_lx):
            #out[y][x] = img[y][x] * m
            out[y][x] = np.matmul(img[y][x], m)
    return out
