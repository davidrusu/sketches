import random
import math
import sys
import struct

labels = []
images = []
n = 1000

def readint(f, size):
    if size == 4:
        return struct.unpack('I', f.read(size))[0]
    if size == 1:
        return struct.unpack('B', f.read(size))[0]

with open('./data/labels', 'rb') as f:
	f.read(4) # magic number
	num_labels = readint(f, 4)
	print(num_labels)
	for i in range(min(n, num_labels)):
		labels.append(readint(f, 1))
	print('read {} labels'.format(len(labels)))


with open('./data/images', 'rb') as f:
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


def centroids(points, closest, k):
	avg = []
	count = [0 for x in range(k)]
	for i in range(k):
		avg.append(([0]*len(points[0])))

	for i in range(len(points)): #for each point
		for j in range(len(points[0])): #for each dimension
			avg[closest[i]][j] += points[i][j]
		count[closest[i]] += 1

	for i in range(k):
		for j in range(len(points[0])):
			if count[i] > 0:
				avg[i][j] /= count[i]
	return avg

def kMeans(k, points, plotting):
	print("Starting kmeans")
	assert k < len(points)
	random.seed()
	centers = []
	while (len(centers) < k):
		p = points[random.randint(0, len(points) - 1)]
		if (p not in centers): #ensure we dont get duplicates
			centers.append(p)


	#print "Initial centers: ", centers
	oldCenters = []
	iteration = 0
	while centers != oldCenters and iteration < 100:
		iteration = iteration + 1
		print ("Iteration ", iteration)

		minDist = [sys.maxsize for x in range(len(points))]
		closest= [sys.maxsize for x in range(len(points))]

		oldCenters = centers

		for i in range(len(centers)):
			for j in range(len(points)):
				dist = distance (centers[i], points[j])
				if minDist[j] > dist:
					minDist[j] = dist
					closest[j] = i
		centers = centroids(points, closest, k)
	return centers, closest

#computes the distance squared between 2 n dimensional tuples
def distance(a, b):
	assert len(a) == len(b)
	d = 0
	for i in range(len(a)):
		d += (a[i]-b[i])*(a[i]-b[i])
	return d

centroids, cluster_assignment = kMeans(100, images, False)

class_count = [[0] * 10 for _ in range(len(centroids))]

for i, cluster in enumerate(cluster_assignment):
    actual = labels[i]
    class_count[cluster][actual] += 1

def arg_max(xs):
    m = 0
    val = xs[0]
    for i in range(1, len(xs)):
        if xs[i] > val:
            m = i
            val = xs[i]
    return m

class_map = [ arg_max(cls) for cls in class_count ]
print(class_count)
canvas = None
 
def setup():
    global canvas
    size(500, 525);
    canvas = createGraphics(500, 500)
    canvas.beginDraw()
    canvas.background(255);
    canvas.endDraw()
    
def classify():
    temp = createGraphics(28, 28)
    temp.beginDraw()
    temp.scale(float(temp.width) / canvas.width, float(temp.height) / canvas.height)
    temp.image(canvas, 0, 0)
    temp.endDraw()
    
    temp.loadPixels()
    img = []
    for p in temp.pixels:
        img.append(brightness(p))
    
    image(temp, 200, 0);
    distances = [0 for _ in range(10)]
    
    for i in range(len(centroids)):
        d = distance(img, centroids[i])
        distances[class_map[i]] += 1/d
    total = sum(distances)
    return " | ".join("{}: {:.0f}".format(i,(d/total) * 100) for i, d in enumerate(distances)) + " " + str(arg_max(distances))
    
def draw():
    if mousePressed:
        canvas.beginDraw()
        canvas.fill(0)
        canvas.ellipse(mouseX, mouseY - 25, 60, 60);
        canvas.endDraw()
    
    if keyPressed:
        if key == 'c':
            canvas.beginDraw()
            canvas.background(255);
            canvas.endDraw()
    
    if frameCount % 60 == 0:
        background(200);
        cls = classify()
        fill(0)
        text("Prediction: " + str(cls), 0, 12)
    image(canvas, 0, 25)
    