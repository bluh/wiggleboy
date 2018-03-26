class Line{
    V3 point1;
    V3 point2;
    
    Line(V3 p1, V3 p2){
        set(p1, p2);
    }
    
    Line set(V3 p1, V3 p2){
        point1 = p1;
        point2 = p2;
        return this;
    }
    
    void render(){
        line(point1.x, point1.y, point1.z, point2.x, point2.y, point2.z);
    }
    
    boolean equals(Object other){
        if(other != null && other instanceof Line){
            return (this.point1.equals(((Line)other).point1) && this.point2.equals(((Line)other).point2)) || (this.point1.equals(((Line)other).point2) && this.point2.equals(((Line)other).point1));
        }
        return false;
    }
    
    String toString(){
        return "[" + point1.toString() + ",  " + point2.toString() + "]";
    }
        
}
