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
}
