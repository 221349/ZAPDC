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
    g_c = (1 - c.Kr - c.Kb)
    return [
        [c.Kr,              g_c,         c.Kb],
        [cb_c*c.Kr,         cb_c*g_c,    cb_c*(c.Kb - 1)],
        [cr_c*(c.Kr - 1),   cr_c*g_c,    cr_c*c.Kb]
        ]

def matrix_YCC2RGB(c):
    X = -1/(2 * (1 - c.Kr))
    T = -1/(2 * (1 - c.Kb))
    R = c.Kr
    G = (1 - c.Kr - c.Kb)
    B = c.Kb

    L = T*X*R*G - T*X*G*(R+B-1) + T*X*G*B
    M = np.array([
        [T*X*G,        0,      -T*G],
        [T*X*(R+B-1),  X*B,    T*R],
        [T*X*G,        X*G,    0]
        ])
    return M/L


def rgb2ycc(img, conversion):
    if(conversion == 'BT_709'):
        m = matrix_RGB2YCC(BT_709)
    else:
        m = matrix_RGB2YCC(BT_601)
    return convert(img, m)

def ycc2rgb(img, conversion):
    if(conversion == 'BT_709'):
        m = np.linalg.inv(matrix_RGB2YCC(BT_709))
    else:
        m = np.linalg.inv(matrix_RGB2YCC(BT_601))
    return convert(img, m)


def convert(img, m):
    img_lx = len(img[0])
    img_ly = len(img)
    out = np.zeros((img_ly, img_lx, 3), 'float')
    for y in range(img_ly):
        for x in range(img_lx):
            #out[y][x] = img[y][x] * m
            out[y][x] = np.matmul(img[y][x], m)
    return out
