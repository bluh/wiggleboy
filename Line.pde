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
        
}
