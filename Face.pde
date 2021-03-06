class Face{
    V3[] verticies;
    Line[] lines;
    
    Face(Line[] lines){
        println("New face:");
        this.lines = lines;
        verticies = new V3[lines.length];
        verticies[0] = lines[0].point1;
        verticies[1] = lines[0].point2;
        println("\tstart: " + verticies[0] + " and " + verticies[1]);
        int index = 1;
        for(int i = 1; i < lines.length; i++){
            V3 nextPoint = null;
            if(lines[i].point1 == verticies[index]){
                nextPoint = lines[i].point2;
            }else if(lines[i].point2 == verticies[index]){
                nextPoint = lines[i].point1;
            }else{
                
            }
            if(nextPoint != null && nextPoint != verticies[0]){
                index++;
                verticies[index] = nextPoint;
                println("\tadded " + verticies[index]);
            }
        }
        println("\ttotal: " + (index + 1));
        //println("\tcenter: " + getCenter());
    }
    
    V3 getCenter(){
        V3 center = new V3(0,0,0);
        for(V3 v: verticies){
            center.move(v);
        }
        return center.mult(1.0 / verticies.length);
    }
    
    void render(){
        beginShape();
        noStroke();
        for(V3 d: verticies){
            vertex(d.x,d.y,d.z);
        }
        endShape(CLOSE);
    }
}
