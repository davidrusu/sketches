import java.util.*; //<>// //<>// //<>//

TerritoryPoint findMinYPoint(ArrayList<TerritoryPoint> points) {
  if (points.size() == 0) {
    return null;
  }
  TerritoryPoint minY = points.get(0);
  for (int i = 1; i < points.size(); i++) {
    if (points.get(i).y < minY.y) {
      minY = points.get(i);
    }
  }
  return minY;
}

float angle(TerritoryPoint a, TerritoryPoint b) {
  float dx = b.x - a.x;
  float dy = b.y - a.y;
  if (dx == 0) {
    dx = 0.0001;
  }
  if (dy == 0) {
    dy = 0.0001;
  }
  float angle = 1 * (-atan(dy / dx) + (min(0, dx) / abs(dx)) * PI + (min(0, dx) / abs(dx))*(min(0, dy)/abs(dy))*PI * 2);
  //float angle = 1 * (atan(dy / dx) * PI + PI/2);
  fill(255);
  //text(angle * 180 / PI, a.x + 0.5 * dx, a.y + 0.5 * dy);
  return angle;
}

void sortByAngle(ArrayList<TerritoryPoint> points, final TerritoryPoint curPoint, final float prevAngle) {
  Collections.sort(points, new Comparator<TerritoryPoint>() {
    public int compare(TerritoryPoint a, TerritoryPoint b) {
      //randomSeed((int) prevAngle);
      //stroke((int)random(255), (int)random(255), (int)random(255));
      //line(a.x, a.y, b.x, b.y);
      float angleA = angle(curPoint, a) - prevAngle;
      float angleB = angle(curPoint, b) - prevAngle;
      //if (angleA > PI) {
      //  angleA = -2 * PI + angleA - PI;
      //} else if (angleA < -PI) {
      //  angleA = 2*PI + angleA + PI;
      //}
      //if (angleB > PI) {
      //  angleB = -2 * PI + angleB - PI;
      //} else if (angleB < -PI) {
      //  angleB = 2 * PI + angleB + PI;
      //}
      if (angleA > 0) {
        angleA = angleA - 2*PI;
      }
      if (angleB > 0) {
        angleB = angleB - 2*PI;
      }
      float diff = angleB - angleA; 
      //diff *= -1;
      if (diff < 0) {
        return -1;
      } else if (diff > 0) {
        return 1;
      } else {
        return 0;
      }
    }
  }
  );
}
float pointDist(TerritoryPoint a, TerritoryPoint b) {
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  return sqrt(dx * dx + dy * dy);
}
ArrayList<TerritoryPoint> nearestPoints(ArrayList<TerritoryPoint> points, TerritoryPoint point, int k) {
  ArrayList<TerritoryPoint> nearestK = new ArrayList<TerritoryPoint>();
  for (TerritoryPoint p : points) {
    float d = pointDist(p, point);
    int j;
    for (j = 0; j < nearestK.size(); j++) {
      if (pointDist(nearestK.get(j), point) > d) {
        break;
      }
    }
    if (j < 0) {
      nearestK.add(p);
    } else if (j < k) {
      nearestK.add(j, p);
    }
    if (nearestK.size() >  k) {
      nearestK.remove(k);
    }
  }
  return nearestK;
}

boolean intersectQ(TerritoryPoint a1, TerritoryPoint b1, TerritoryPoint a2, TerritoryPoint b2) {

  float dx1 = b1.x - a1.x;
  float dy1 = b1.y - a1.y;
  float dx2 = b2.x - a2.x;
  float dy2 = b2.y - a2.y;
  float yInt1 = a1.y - dy1/dx1 * a1.x;
  //float y = dy1 / dx1 * x + yInt1;
  float yInt2 = a2.y - dy2/dx2 * a2.x;
  //float y = dy2 / dx2 * x + yInt2;
  float x = (yInt2 - yInt1) / (dy1/dx1 - dy2/dx2);
  float dxInt1 = b1.x - x;
  float dxInt2 = b2.x - x;
  float d1 = dxInt1 / dx1;
  float d2 = dxInt2 / dx2;
  boolean verdict = 0 < d1 && d1 < 1 && 0 < d2 && d2 < 1;
  //if (verdict) {
  //  fill(0,255,0, 100);
  //} else {
  //  fill(255, 0, 0, 100);
  //}
  //ellipse(x, dy1/dx1 * x + yInt1, 4, 4);
  return verdict;
}

ArrayList<PShape> concaveHulls(ArrayList<TerritoryPoint> points, int k) {
  ArrayList<TerritoryPoint> initialPoints = (ArrayList<TerritoryPoint>) points.clone();
  k = max(k, 3);
  ArrayList<PShape> result = new ArrayList<PShape>();
  int numPoints = points.size();

  if (points.size() < 3) {
    return result;
  }

  if (points.size() == 3) {
    PShape sh = createShape();
    sh.beginShape();
    sh.stroke(255);
    sh.noFill();
    sh.vertex(points.get(0).x, points.get(0).y);
    sh.vertex(points.get(1).x, points.get(1).y);
    sh.vertex(points.get(2).x, points.get(2).y);
    sh.endShape();
    result.add(sh);
    return result;
  }
  k = min(k, points.size() - 1);
  TerritoryPoint firstPoint = findMinYPoint(points);
  ArrayList<TerritoryPoint> hull = new ArrayList<TerritoryPoint>();
  hull.add(firstPoint);
  points.remove(firstPoint);
  float prevAngle = 0;
  TerritoryPoint prevPoint = null;
  TerritoryPoint curPoint = firstPoint;
  int step = 2;
  while ((curPoint != firstPoint || step==2) && points.size() > 0) {
    if (step == 4) {
      points.add(firstPoint);
    }
    ArrayList<TerritoryPoint> kNearest = nearestPoints(points, curPoint, k);

    //if ( step == 3 ) {//millis() / 1000 % initialPoints.size() == step - 2) {
    // println(kNearest.size());
    // for (TerritoryPoint p: kNearest) {
    //   fill(255, 0, 255);
    //   ellipse(p.x, p.y, 10, 10);
    // }

    // fill(0,255,255);
    // ellipse(curPoint.x, curPoint.y, 10, 10);
    //}
    sortByAngle(kNearest, curPoint, prevAngle);
    boolean its = true;
    int i = 0;
    while (its && i < kNearest.size()) {
      int lastPoint = 0;
      if (kNearest.get(i) == firstPoint) {
        lastPoint = 1;
      }
      int j = 2;
      its = false;
      while (!its && j < hull.size()-lastPoint) {
        its = intersectQ(hull.get(hull.size()-1), kNearest.get(i), 
          hull.get(hull.size()-1-j), hull.get(hull.size()-j));
        j++;
      }
      i++;
    }
    i--;
    prevPoint = curPoint;
    curPoint = kNearest.get(min(i, kNearest.size() - 1));
    if (its) {
      //println("still intersecting");
      //randomSeed(millis());
      //fill((int)random(255));
      //ellipse(curPoint.x, curPoint.y, 25, 25);
      //return concaveHulls(initialPoints, k+1);
    }
    hull.add(curPoint);
    prevAngle = angle(prevPoint, curPoint);
    points.remove(curPoint);
    step++;
  }
  //ArrayList<PShape> others = concaveHulls(points, k);
  PShape sh = createShape();
  sh.beginShape();
  sh.stroke(255);
  sh.noFill();
  sh.fill(255);
  int c = 255;
  float i = 0;
  for (TerritoryPoint p : hull) {
    sh.stroke(255 * (i/hull.size()));
    sh.vertex(p.x, p.y);
    i += 1;
  }
  sh.endShape();
  result.add(sh);
  //result.addAll(others);
  return result;
}

class Edge {
  TerritoryPoint a;
  TerritoryPoint b;

  Edge(TerritoryPoint a, TerritoryPoint b) {
    this.a = a;
    this.b = b;
  }
}

ArrayList<ArrayList<TerritoryPoint>> concaveHulls(ArrayList<TerritoryPoint> points, float alpha) {
  ArrayList<ArrayList<TerritoryPoint>> result = new ArrayList<ArrayList<TerritoryPoint>>();
  float radius = 1/alpha;
  ArrayList<Edge> edges = new ArrayList<Edge>();
  for (int i = 0; i < points.size(); i++) {
    TerritoryPoint a = points.get(i);
    for (int j = i+1; j < points.size(); j++) {
      TerritoryPoint b = points.get(j);
      float secant = pointDist(a, b);
      if (secant >= radius * 2) {
        continue;
      }

      float y = secant/(2*radius);
      float x = radius*sqrt(1 - y * y);
      float dx = b.x - a.x;
      float dy = b.y - a.y;
      float ny = -dx;
      float nx = dy;
      ny = (ny * x) / secant;
      nx = (nx * x) / secant;
      float ballx1 = nx+ dx / 2 + a.x;
      float bally1 = ny + dy / 2 + a.y;
      float ballx2 = -nx + dx / 2 + a.x;
      float bally2 = -ny + dy / 2 + a.y;
      boolean ball1Empty = true;
      boolean ball2Empty = true;
      for (int k = 0; k < points.size(); k++) {
        if (k == i || k == j) {
          continue;
        }
        TerritoryPoint c = points.get(k);
        float ddx = ballx1 - c.x;
        float ddy = bally1 - c.y;
        float d = sqrt(ddx * ddx + ddy * ddy);
        if (d < radius) {
          ball1Empty = false;
        }
        ddx = ballx2 - c.x;
        ddy = bally2 - c.y;
        d = sqrt(ddx * ddx + ddy * ddy);
        if (d < radius) {
          ball2Empty = false;
        }
      }

      if (ball1Empty || ball2Empty) {
        edges.add(new Edge(a, b));
        if (debug) {
          noStroke();
          fill(255, 0, 0);
          ellipse(a.x, a.y, 3, 3);
          ellipse(b.x, b.y, 3, 3);
          stroke(255, 100);
          noFill();
          if (ball1Empty) {
            ellipse(max(0, min(width, ballx1)), bally1, radius * 2, radius * 2);
          }
          if (ball2Empty) {
            ellipse(max(0, min(width, ballx2)), bally2, radius * 2, radius * 2);
          }
        }
      }
    }
  }

  // need to prune the edges
  boolean keepGoing = true;
  while (keepGoing) {
    ArrayList<Edge> toRemove = new ArrayList<Edge>();
    for (int i = 0; i < edges.size(); i++) {
      Edge edge = edges.get(i);
      stroke(255, 0 , 0);
      line(edge.a.x, edge.a.y, edge.b.x, edge.b.y);
      boolean seenA = false;
      boolean seenB = false;

      for (int j = 0; j < edges.size(); j++) {
        if (j == i) {
          continue;
        }
        Edge other = edges.get(j);
        if (other.a == edge.a || other.b == edge.a) {
          seenA = true;
        }
        if (other.a == edge.b || other.b == edge.b) {
          seenB = true;
        }
        if (seenA && seenB) {
          break;
        }
      }
      if (!seenA || !seenB) {
        toRemove.add(edge);
      }
    }
    for (Edge edge : toRemove) {
      edges.remove(edge);
    }
    keepGoing = toRemove.size() > 0;
  }

  while (edges.size() > 0) {
    ArrayList<TerritoryPoint> hull = new ArrayList<TerritoryPoint>();
    Edge edge = edges.get(0);
    stroke(255, 0, 0);
    line(edge.a.x, edge.a.y, edge.b.x, edge.b.y);
    hull.add(edge.a);
    hull.add(edge.b);
    edges.remove(0);
    TerritoryPoint prev = edge.b;
    keepGoing = true;
    while (keepGoing) {
      keepGoing = false;
      for (int i = 0; i < edges.size(); i++) {
        Edge test_edge = edges.get(i);
        if (test_edge.a == prev) {
          hull.add(test_edge.b);
          prev = test_edge.b;
          edges.remove(i);
          keepGoing = true;
          break;
        } else if (test_edge.b == prev) {
          hull.add(test_edge.a);
          prev = test_edge.a;
          edges.remove(i);
          keepGoing = true;
          break;
        }
      }
    }

    //stroke(255, 0, 0);
    //noFill();
    //TerritoryPoint prev = edge.a; 
    //for(TerritoryPoint p: hull) {
    //line(prev.x, prev.y, p.x, p.y);
    //}
    //    
    result.add(hull);
  }

  return result;
}

PShape hullToPShape(ArrayList<TerritoryPoint> hull) {
  PShape sh = createShape();
  sh.beginShape();
  sh.stroke(255);
  sh.fill(255);
  //sh.stroke(random(255), random(255), random(255));
  for (TerritoryPoint p : hull) {
    sh.vertex(p.x, p.y);
  }
  TerritoryPoint firstPoint = hull.get(0);
  sh.vertex(firstPoint.x, firstPoint.y);
  sh.endShape();
  return sh;
}