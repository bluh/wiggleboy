class Ray{
    V3 start;
    V3 unit;
    
    Ray(V3 start, V3 end){
        this.start = start;
        this.unit = end.sub(start).unit();
    }
    
    float distanceToPoint(V3 point){
        V3 pUnit = point.sub(start).unit();
        float a = (float) Math.acos(unit.dot(pUnit)/(unit.mag() * pUnit.mag()));
        return (start.sub(point).mag() * (float) Math.sin(a));
    }
}
