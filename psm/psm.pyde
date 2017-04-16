from collections import *
from math import *

num_percepts = 3
percept_colors = [color(255, 0, 0, 50), color(0, 255, 0, 50), color(0, 0, 255, 50)
, color(255, 255, 0, 50), color(0, 255, 255, 50)]

class Node:
    def __init__(self):
        self.percept_visits = [0] * num_percepts
        self.edges = defaultdict(list)
    
    def dominant_percept(self):
        return sorted(enumerate(self.percept_visits), key=lambda x: x[1])[-1][0]
    
    def visits(self):
        return sum(self.percept_visits)

class Point:
    def __init__(self, index):
        self.index = index
        self.x = random(width)
        self.y = random(height)
        self.vx = 0
        self.vy = 0
    
    def update(self):
        center_k = 0.001
        self.vx += (width / 2 - self.x) * center_k
        self.vy += (height / 2 - self.y) * center_k
        
        for p in range(num_percepts):
            for j, _ in psm[self.index].edges[p]:
                p2 = points[j]
                dx = p2.x - self.x
                dy = p2.y - self.y
                d = max(1, sqrt(dx * dx + dy * dy))
                nx = dx / d
                ny = dy / d
                k = 0.001 * (d - 20)
                self.vx += k * nx
                self.vy += k * ny
                p2.vx -= k * nx
                p2.vy -= k * ny
                
        for j, p in enumerate(points):
            if j == self.index:
                continue
            dx = p.x - self.x
            dy = p.y - self.y
            d = max(50, sqrt(dx * dx + dy * dy))
            nx = dx / d
            ny = dy / d
            k = -200  / (d * d)
            self.vx += k * nx
            self.vy += k * ny
            p.vx -= k * nx
            p.vy -= k * ny
        
        self.vx *= 0.8
        self.vy *= 0.8
        self.x += self.vx
        self.y += self.vy
    
    def draw(self):
        node = psm[self.index]
        for p in range(num_percepts):
            c = percept_colors[p]
            stroke(c)
            strokeWeight(1)
            for i, prob in node.edges[p]:
                p2 = points[i]
                strokeWeight(prob * 10)
                line(self.x, self.y, p2.x, p2.y)
                fill(c)
                ellipse(self.x + (p2.x - self.x) * 0.75, self.y + (p2.y - self.y) * 0.75, 5, 5)
        
        noFill()
        if state == self.index:
            strokeWeight(5)
            stroke(percept_colors[0 if len(history) == 0 else history[-1]])
            stroke(0, 0, 0)
        else:
            strokeWeight(1)
            stroke(0);
        ellipse(self.x, self.y, 20, 20)
        
        fill(0);
        text(str(node.dominant_percept()), self.x-2, self.y + 5)

psm = [Node()]
state = 0
points = []

history = []
history_states = [] # [(start_state, end_state, percept)] 
actual_history = []

def normalize(dist):
    total = sum(dist)
    for i, p in enumerate(dist):
        dist[i] = p / total

def normalize_edges(edges):
    for i in range(len(edges)):
        s, p = edges[i]
        edges[i] = (s, max(0.001, p))
    total_p = sum([p for _, p in edges])
    for i in range(len(edges)):
        s, p = edges[i]
        edges[i] = (s, p / total_p)
        
        
def activation(x, stretch, center):
    return atan(x / stretch - center) / pi + 1/2

def sample(distribution):
    rv = random(1)

    cum_p = 0
    for node, p in sorted(distribution, key=lambda x: x[1], reverse=True):
        cum_p += p
        if rv < cum_p:
            return node
    raise Exception("dist doesn't sum to 1: {}".format(str(dist)))

def backpropagate():
    dom_percept = psm[state].dominant_percept()
    actual_percept = history[-1]
    bump = 2 if dom_percept == actual_percept else -0.1
    i = 1
    for start_state, end_state, percept in reversed(history_states):
        edges = psm[start_state].edges[percept]
        for index, e in enumerate(edges):
            next_state, p = e
            if next_state == end_state:
                edges[index] = (next_state, p + bump / (i ** 2))
                break
        normalize_edges(edges)
        i += 1

def transition(p):
    global state
    history.append(p)
    actual_history.append(psm[state].dominant_percept())
    
    node = psm[state]
    node.percept_visits[p] += 1
    backpropagate()
    edges = node.edges[p]
    
    if edges == []:
        edges.append((int(random(len(psm))), 1))
    next_state = sample(edges)

    confidence = atan(node.visits() / num_percepts - 5) / pi + 1/2
    mean = node.visits() / num_percepts
    sd = 0
    for p_v in node.percept_visits:
        sd += (p_v - mean) **2
    sd = sqrt(sd / num_percepts)
    
    rv = random(1)
    pvalue = sd / max(node.percept_visits)
    
    if rv * confidence > pvalue:
        if random(1) > (atan(len(edges) - 1) / pi + 1/2) and len(edges) < len(psm):
            next_state = int(random(len(psm) - len(edges))) + len(edges) - 1
            edges.append((next_state, 0.5))
        else:
            new_node = Node()
            next_state = len(psm)
            psm.append(new_node)
            edges.append((next_state, 0.5))
        
        normalize_edges(edges)
    history_states.append((state, next_state, p))
    state = next_state
    
    
    
def setup():
    size(500, 500)
    
    
def update():
    t = 10
    if frameCount % t == 0:
        transition(int(frameCount / t) % num_percepts)
    
    for i, n in enumerate(psm):
        if len(points) <= i:
            points.append(Point(index=i))
    
    for p in points:
        p.update()
        

def draw():
    background(255)
    
    update()
    
    for p in points:
        p.draw()
    
    menu()
    
def mousePressed():
    if mouseY < 50:
        percept = int(mouseX / (width / num_percepts))
        transition(percept)
        
def menu():
    strokeWeight(1)
    menu_height = 50
    button_size = width / num_percepts
    for i in range(num_percepts):
        fill(10,50,200);
        stroke(0) 
        rect(i * button_size, 0, button_size, menu_height)
        fill(255)
        noStroke()
        text(str(i), (i + 0.5) * button_size, menu_height * 0.5)
    
    fill(0)
    text(str(history[-30:]), 10, menu_height + 25)
    text(str(actual_history[-30:]), 10, menu_height + 50)
    hit_rate = float(len([ p1 for p1, p2 in zip(history, actual_history) if p1 == p2 ])) / max(1, len(history))
    text(str(hit_rate), 10, menu_height + 75)
    
        
    
    
    
        
        