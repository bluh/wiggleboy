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
}
