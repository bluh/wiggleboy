class Ray{
    V3 start;
    V3 unit;
    
    Ray(V3 start, V3 end){
        set(start, end);
    }
    
    Ray set(V3 start, V3 end){
        this.start = start;
        this.unit = end.sub(start).unit();
        return this;
    }
    
    Ray setEnd(V3 end){
        return set(this.start, end);
    }
    
    float distanceToPoint(V3 point){
        V3 pUnit = point.sub(start).unit();
        float a = (float) Math.acos(unit.dot(pUnit)/(unit.mag() * pUnit.mag()));
        return (start.sub(point).mag() * (float) Math.sin(a));
    }
    
    float[] connectToLine(V3 pStart, V3 pUnit){
        pUnit = pUnit.unit();
        float a = unit.mag() * unit.mag();
        float b = unit.dot(pUnit);
        float c = pUnit.mag() * pUnit.mag();
        float d = unit.dot(start.sub(pStart));
        float e = pUnit.dot(start.sub(pStart));
        float[] result;
        if(a * c - b * b == 0){
            //these lines are parallel.
            result = new float[] {0,0};
        }else{
            result = new float[] {
                ((b * e - c * d)/(a * c - b * b)),
                ((a * e - b * d)/(a * c - b * b))
            };
        }
        return result;
    }
    
    boolean intersectsFace(Face obj){
        V3 p0 = obj.verticies[0];
        V3 p1 = null;
        V3 p2 = null;
        V3 norm = null;
        V3 intersect = null;
        V3 last = null;
        int i;
        for(int x = 1; x < obj.verticies.length + 1; x++){
            i = x % obj.verticies.length;
            if(p1 == null){
                p1 = obj.verticies[i];
                p2 = obj.verticies[i+1];
                norm = (p1.sub(p0)).cross(p2.sub(p0)).unit();
                last = p1;
                float dist = (p0.sub(start).dot(norm)) / (unit.dot(norm));
                intersect = start.add(unit.mult(dist));
                i++;
            }
            if(obj.verticies[i].sub(p0).dot(norm) == 0){
                V3 u = last.sub(p0);
                V3 v = obj.verticies[i].sub(p0);
                V3 w = intersect.sub(p0);
                float denom = (float) Math.pow(u.dot(v),2) - u.dot(u) * v.dot(v);
                float uDist = (u.dot(v) * w.dot(v) - v.dot(v) * w.dot(u)) / denom;
                float vDist = (u.dot(v) * w.dot(u) - u.dot(u) * w.dot(v)) / denom;
                if(uDist < 1 && uDist > 0 && vDist < 1 && vDist > 0 && uDist + vDist > 0 && uDist + vDist < 1){
                    return true;
                }
                last = obj.verticies[i];
            }else{
                p0 = obj.verticies[(4 + i - 1) % 4];
                p1 = obj.verticies[i];
                p2 = obj.verticies[(i + 1) % obj.verticies.length];
                norm = (p1.sub(p0)).cross(p2.sub(p0)).unit();
                last = p1;
                float dist = (p0.sub(start).dot(norm)) / (unit.dot(norm));
                intersect = start.add(unit.mult(dist));
                i++;
            }
        }
        return false;
    }
}
