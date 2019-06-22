#!/usr/bin/env python

import os, sys
import matplotlib.image as mpimg 
import matplotlib.pyplot as plt
import numpy as np
import math

################################
## mosaic/DEmosaic functions: ##
################################
def mosaic(img, mask):
    mask_lx = len(mask[0])
    mask_ly = len(mask)
    img_lx = len(img[0])
    img_ly = len(img)
#    out = np.array([[0]*img_lx]*img_ly, dtype='float')
    out = np.zeros((img_ly,img_lx), 'float')
    for y in range(img_ly):
        for x in range(img_lx):
            out[y][x] = (img[y][x][0]*mask[y%mask_ly][x%mask_lx][0] +
                         img[y][x][1]*mask[y%mask_ly][x%mask_lx][1] +
                         img[y][x][2]*mask[y%mask_ly][x%mask_lx][2])
    
    return out

def demosaic(img, mask):
    mask_lx = len(mask[0])
    mask_ly = len(mask)
    img_lx = len(img[0]) - 1
    img_ly = len(img) - 1
    out = np.zeros((img_ly,img_lx,3), 'float')
    #np.array([[3]*img_lx]*img_ly, dtype='float')
    #print (img[50][60])
    z = 0
    for y in range(img_ly):
        for x in range(img_lx):
            for c in range(3):
                out[y][x][c] = (img[y][x]*mask[y%mask_ly][x%mask_lx][c] + 
                                img[y][x+1]*mask[y%mask_ly][(x+1)%mask_lx][c] +
                                img[y+1][x]*mask[(y+1)%mask_ly][x%mask_lx][c] + 
                                img[y+1][x+1]*mask[(y+1)%mask_ly][(x+1)%mask_lx][c]) / (
                                    mask[y%mask_ly][x%mask_lx][c] + 
                                    mask[y%mask_ly][(x+1)%mask_lx][c] +
                                    mask[(y+1)%mask_ly][x%mask_lx][c] + 
                                    mask[(y+1)%mask_ly][(x+1)%mask_lx][c])
    return out

def demosaic_adv(img, mask, window, step):
    mask_lx = len(mask[0])
    mask_ly = len(mask)
    img_lx = math.trunc( (len(img[0]) - (window[1] - 1) ) / step[1])
    img_ly = math.trunc( (len(img) - (window[0] - 1) ) / step[0])
    out = np.zeros((img_ly,img_lx,3), 'float')
    #np.array([[3]*img_lx]*img_ly, dtype='float')
    #print (img[50][60])
    z = 0
    for ly in range(img_ly):
        y = ly * step[0]
        for lx in range(img_lx):
            x = lx * step[1]
            for c in range(3):
                csum = 0
                msum = 0
                for wy in range(window[0]):
                    for wx in range (window[1]):
                        csum += img[y + wy][x + wx]*mask[(y+wy)%mask_ly][(x+wx)%mask_lx][c]
                        msum += mask[(y+wy)%mask_ly][(x+wx)%mask_lx][c]
                out[ly][lx][c] = csum/msum
    return out


###########
## CFAs: ##
###########
def BAYER_MASK():
    return [
        [[0,1,0], [1,0,0]],
        [[0,0,1], [0,1,0]]
            ]

def XTRANS_MASK():
    return [
        [[0,1,0], [0,0,1], [0,1,0],   [0,1,0], [1,0,0], [0,1,0]],
        [[1,0,0], [0,1,0], [1,0,0],   [0,0,1], [0,1,0], [0,0,1]],
        [[0,1,0], [0,0,1], [0,1,0],   [0,1,0], [1,0,0], [0,1,0]],
        
        [[0,1,0], [1,0,0], [0,1,0],   [0,1,0], [0,0,1], [0,1,0]],
        [[0,0,1], [0,1,0], [0,0,1],   [1,0,0], [0,1,0], [1,0,0]],
        [[0,1,0], [1,0,0], [0,1,0],   [0,1,0], [0,0,1], [0,1,0]],
            ]


os.makedirs( "sprawozdanie/img", exist_ok=True)

img = mpimg.imread('4demosaicking.png') 
mos = mosaic(img, BAYER_MASK())
dmos = demosaic(mos, BAYER_MASK())
mpimg.imsave('sprawozdanie/img/bayer_mos.png', demosaic_adv(mos, BAYER_MASK(), [1, 1], [1, 1])) 
mpimg.imsave('sprawozdanie/img/bayer_dmos.png', dmos) 

mos = mosaic(img, XTRANS_MASK())
dmos = demosaic(mos, XTRANS_MASK())
mpimg.imsave('sprawozdanie/img/xtrans_mos.png', demosaic_adv(mos, XTRANS_MASK(), [1, 1], [1, 1])) 
mpimg.imsave('sprawozdanie/img/xtrans_dmos.png', dmos) 

dmos = demosaic_adv(mos, XTRANS_MASK(), [3, 3], [1, 1])
mpimg.imsave('sprawozdanie/img/xtrans_dmos_adv_w3.png', dmos)
 
#plt.imshow(dmos, cmap='gray',  interpolation='nearest') 
#plt.imshow(dmos)
#plt.show()
