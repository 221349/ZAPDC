#!/usr/bin/env python

import matplotlib.image as mpimg 
import matplotlib.pyplot as plt
import numpy as np

def mosaic(img, mask):
    mask_lx = len(mask[0])
    mask_ly = len(mask)
    img_lx = len(img[0])
    img_ly = len(img)
    out = np.array([[0]*len(img[0])]*len(img), dtype='float')
    #out = [[0 for i in range(10)] for j in range(20)] 
    for y in range(img_ly):
        for x in range(img_lx):
            out[y][x] = (img[y][x][0]*mask[y%mask_ly][x%mask_lx][0] +
                         img[y][x][1]*mask[y%mask_ly][x%mask_lx][1] +
                         img[y][x][2]*mask[y%mask_ly][x%mask_lx][2])
    
    return out


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


img = mpimg.imread('4demosaicking.png') 

plt.imshow(mosaic(img, XTRANS_MASK()), cmap='gray',  interpolation='nearest') 
plt.show()


#print (img.shape)
#plt.imshow(img) 
#plt.show()
