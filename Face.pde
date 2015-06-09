class Face{
  final int SHAPE;
  V3[] verticies;
  
  Face(V3[] verts){
    verticies = verts;
    SHAPE = verticies.length;
  }
  
  void render(){
    beginShape();
    fill(255,255,255,100);
    for(V3 d: verticies){
      vertex(d.x,d.y,d.z);
    }
    endShape(CLOSE);
  }
}
  
