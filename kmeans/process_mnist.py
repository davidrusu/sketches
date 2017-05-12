import random
import math
import sys
import struct

labels = []
images = []
n = 100

def readint(f, size):
    if size == 4:
        return struct.unpack('I', f.read(size))[0]
    if size == 1:
        return struct.unpack('B', f.read(size))[0]

with open('./mnist/labels', 'rb') as f:
	f.read(4) # magic number
	num_labels = readint(f, 4)
	print(num_labels)
	for i in range(min(n, num_labels)):
		labels.append(readint(f, 1))
	print('read {} labels'.format(len(labels)))


with open('./mnist/images', 'rb') as f:
	f.read(4) # magic number
	num_images = readint(f, 4)
	num_rows = readint(f, 4)
	num_cols = readint(f, 4)
	for i in range(min(n, num_labels)):
		img = []
		for j in range(num_rows * num_cols):
			img.append(readint(f, 1))
		images.append(img)
	print('read {} images'.format(len(images)))

for label, img in zip(labels, images):
	print(", ".join(list(map(str, img)) + [label]))
