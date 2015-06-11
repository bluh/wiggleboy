class Face{
    V3[] verticies;
    Line[] lines;
    
    Face(Line[] lines){
        println("New face:");
        this.lines = lines;
        verticies = new V3[lines.length];
        verticies[0] = lines[0].point1;
        verticies[1] = lines[0].point2;
        println("start: " + verticies[0] + " and " + verticies[1]);
        int index = 1;
        for(int i = 1; i < lines.length; i++){
            V3 nextPoint;
            if(lines[i].point1 == verticies[index]){
                nextPoint = lines[i].point2;
            }else{
                nextPoint = lines[i].point1;
            }
            if(nextPoint != verticies[0]){
                index++;
                verticies[index] = nextPoint;
                println("added " + verticies[index]);
            }
        }
        println("total: " + index);
    }
    
    void render(){
        beginShape();
        fill(255,255,255,100);
        noStroke();
        for(V3 d: verticies){
//            println(d);
            vertex(d.x,d.y,d.z);
        }
        endShape(CLOSE);
    }
}
    
