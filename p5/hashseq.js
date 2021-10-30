let next_node_id = 0;
let RADIUS = 12;

function node({pos, character, lefts, rights}) {
    let id = next_node_id;
    next_node_id += 1;
    return {
	pos,
	vel: createVector(),
	character,
	id,
	lefts,
	rights,
	radius: RADIUS,
    }
}

let nodeContainsPoint = (node, x, y) => {
    let d = dist(node.pos.x, node.pos.y, x, y);
    return d < node.radius * 0.5;
}

let drawNodeEdges = ({pos, lefts, rights}) => {
    strokeWeight(1);
    stroke(0);
    noFill();
    for (l of lefts) {
	let d = max(1, l.pos.dist(pos)) * 1;
	curve(pos.x, pos.y + d, pos.x, pos.y, l.pos.x, l.pos.y, l.pos.x, l.pos.y + d);
    }

    for (r of rights) {
	let d = max(1, r.pos.dist(pos)) * 1;
	curve(pos.x, pos.y - d, pos.x, pos.y, r.pos.x, r.pos.y, r.pos.x, r.pos.y - d);
    }
};


let drawNode = ({pos, radius, character, id, lefts, rights}) => {
    strokeWeight(1);
    stroke(0);
    fill(255, 200);
    rect(pos.x, pos.y, radius * 2, radius * 2);

    noStroke();
    fill(0);
    text(character, pos.x, pos.y);
    text(id, pos.x, pos.y + radius  + 5);
};

let updateNode = (n) => {
    let k = 1;
    let v = 0.9;
    let L_low = n.radius / 2;
    let L = n.radius * 2;
    let F = createVector();
    for (o_n of n.lefts) {
	let targetX = n.pos.x - L;
	let d = targetX - o_n.pos.x
	if (d < 0) {
	    o_n.vel.x -= v;
	    n.vel.x += v;
	} else {
	    // o_n.vel.x += 0.1 * k * d;
	}
    }
    for (o_n of n.rights) {
	let targetX = n.pos.x + L;
	let d = targetX - o_n.pos.x
	if (d > 0) {
	    o_n.vel.x += v;
	    n.vel.x -= v;
	} else {
	    // o_n.vel.x += 0.1 * k * d;
	}
    }


    // for (o_n of n.rights) {
    // 	let d = o_n.pos.dist(n.pos);
    // 	let targetX = n.pos.x + L;
    // 	let tD = (targetX - o_n.pos.x);
    // 	if (tD <  L) {
    // 	    tD *= d * k;
    // 	} else {
    // 	    tD *= 0;
    // 	}

    // 	o_n.vel.x += tD;
    // }

    n.vel.mult(0.5);
    n.pos.add(n.vel);

    // // n.pos.add(F);

    // for (l of n.lefts) {
    // 	l.pos.sub(F)
    // }

    // for (r of n.rights) {
    // 	r.pos.sub(F)
    // }
}

function randomPos() {
    return createVector(
	random(width),
	random(height)
    );
}

let nodes = [];

function setup() {
    createCanvas(1000, 1000);
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    textSize(20);
}

let cursor = {
    lefts: [],
    rights: [],
}

let cursorPos = (cursor) => {
    let shiftVector = createVector(RADIUS, 0);

    let leftPositions = cursor.lefts
	.map(n => n.pos.copy())
	.map(p => p.add(shiftVector));

    let rightPositions = cursor.rights
	.map(n => n.pos.copy())
	.map(p => p.sub(shiftVector));

    let positions = leftPositions.concat(rightPositions);
    
    let positionSum = positions
	.reduce((a, b) => a.add(b), createVector());

    let n_nodes = cursor.lefts.length + cursor.rights.length;
    if (n_nodes > 0) {
	return positionSum.div(n_nodes);
    } else {
	return createVector(width / 2, height / 2);
    }
}

function drawCursor(c) {
    let pos = cursorPos(c)
    let height = RADIUS * 2;
    let serif = 2;

    stroke(240, 200, 0);
    strokeWeight(3);
    noFill();

    for (l of c.lefts) {
	let d = max(1, l.pos.dist(pos)) * 1;
	curve(pos.x, pos.y + d, pos.x, pos.y, l.pos.x, l.pos.y, l.pos.x, l.pos.y + d);
    }

    for (r of c.rights) {
	let d = max(1, r.pos.dist(pos)) * 1;
	curve(pos.x, pos.y - d, pos.x, pos.y, r.pos.x, r.pos.y, r.pos.x, r.pos.y - d);
    }

    line(pos.x - serif, pos.y - height, pos.x + serif, pos.y - height);
    line(pos.x - serif, pos.y + height, pos.x + serif, pos.y + height);
    line(pos.x, pos.y - height, pos.x, pos.y + height);
}

function insertChar(cursor, character) {
    let pos = cursorPos(cursor);
    let n = node({
	pos,
	character,
	lefts: [...cursor.lefts],
	rights: [...cursor.rights]
    });
    nodes.push(n);
    cursor.lefts = [n];
}

function draw() {
    background(255);

    for (a of nodes) {
	for (b of nodes) {
	    let r = 0.01;
	    let dx = b.pos.x - a.pos.x + random(-r, r);
	    let dy = b.pos.y - a.pos.y + random(-r, r);
	    if (abs(dx) < RADIUS * 2 && abs(dy) < RADIUS * 2) {
		if (abs(dx) > abs(dy)) {
		    let vx = dx / (abs(dx) + 1);
		    a.vel.x -= vx;
		    b.vel.x += vx;
		} else {
		    let vy = dy / (abs(dy) + 1);
		    a.vel.y -= vy;
		    b.vel.y += vy;
		}
	    }
	}
    }
    nodes.forEach(updateNode);


    nodes.forEach(drawNodeEdges);
    nodes.forEach(drawNode);
    drawCursor(cursor);


    input();
}

function mouseClicked() {
    for (n of nodes) {
	if (nodeContainsPoint(n, mouseX, mouseY)) {
	    cursor.lefts = [n];
	    cursor.rights = n.rights;
	}
    }
}

function mouseDragged() {
    for (n of nodes) {
	if (nodeContainsPoint(n, mouseX, mouseY)) {
	    n.pos.x = mouseX;
	    n.pos.y = mouseY;
	    break;
	}
    }
}

function keyPressed() {
    if (keyCode == LEFT_ARROW) {
	if (cursor.lefts.length > 0) {
	    let targetN = cursor.lefts[0];
	    cursor.rights = cursor.lefts;
	    cursor.lefts = [...targetN.lefts];
	}
    } else if (keyCode == RIGHT_ARROW) {
	if (cursor.rights.length > 0) {
	    let targetN = cursor.rights[0];
	    cursor.lefts = cursor.rights;
	    cursor.rights = [...targetN.rights];
	}
    } else {
	insertChar(cursor, key);
    }
}

function input() {
}
