#!/usr/bin/env python3

import numpy as np
import matplotlib.image as mpimg 
import matplotlib.pyplot as plt

import pywt
import pywt.data


# Load image
original = mpimg.imread('org.png')

# Wavelet transform of image, and plot approximation and details
titles = ['Approximation', ' Horizontal detail',
          'Vertical detail', 'Diagonal detail']
coeffs2 = pywt.dwt2(original[:,:,1], 'haar')
LL, (LH, HL, HH) = coeffs2
fig = plt.figure(figsize=(12, 3))
for i, a in enumerate([LL, LH, HL, HH]):
    ax = fig.add_subplot(1, 4, i + 1)
    ax.imshow(a, interpolation="nearest", cmap=plt.cm.gray)
    ax.set_title(titles[i], fontsize=10)
    ax.set_xticks([])
    ax.set_yticks([])

orIG = pywt.idwt2(coeffs2, 'haar')
fig2 = plt.figure(figsize=(12, 3))
ax = fig2.add_subplot(1, 1, 1)

ax.imshow(orIG, interpolation="nearest", cmap=plt.cm.gray)

fig2.tight_layout()
fig.tight_layout()
plt.show()

#plt.show()


#for i, a in enumerate([LL, LH, HL, HH]):
 #   ax = fig2.add_subplot(1, 4, i + 1)
#    ax.imshow(a, interpolation="nearest", cmap=plt.cm.gray)
#    ax.set_title(titles[i], fontsize=10)
#    ax.set_xticks([])
#    ax.set_yticks([])
