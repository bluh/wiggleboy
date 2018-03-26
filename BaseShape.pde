class BaseShape{
    V3 position;
    V3[] verticies;
    Line[] lines;
    Face[] faces;
    
    BaseShape(V3[] verts, Line[] lines, Line[][] faceData){
        this(verts, lines, faceData, new V3(0,0,0));
    }
    
    BaseShape(V3[] verts, Line[] lines, Line[][] faceData, V3 position){
        this.position = position;
        this.verticies = verts;
        this.lines = lines;
        faces = new Face[faceData.length];
        int index = 0;
        for(V3 vert: verts){
            vert.move(position);
        }
        for(Line[] lineEx: faceData){
            faces[index] = new Face(lineEx);
            index++;
        }
    }
    
    BaseShape(ArrayList<V3> verts, ArrayList<Line> lines, ArrayList<Line[]> faceData, V3 position){
        this.position = position;
        this.verticies = new V3[verts.size()];
        for(int i = 0; i < verts.size(); i ++){
            this.verticies[i] = verts.get(i);
            this.verticies[i].move(position);
        }
        this.lines = new Line[lines.size()];
        for(int i = 0; i < lines.size(); i ++){
            this.lines[i] = lines.get(i);
        }
        faces = new Face[faceData.size()];
        int index = 0;
        for(Line[] lineEx: faceData){
            println("New face[" + index + "]:");
            printArray(lineEx);
            faces[index] = new Face(lineEx);
            index++;
        }
    }
    
    BaseShape move(float x, float y, float z){
        for(V3 vert: verticies){
            vert.move(x, y, z);
        }
        position.move(x, y, z);
        return this;
    }
    
    BaseShape move(V3 amt){
        for(V3 vert: verticies){
            vert.move(amt);
        }
        position.move(amt);
        return this;
    }
    
    BaseShape set(float x, float y, float z){
        move(x - position.x, y - position.y, z - position.z);
        return this;
    }
    
    BaseShape set(V3 vec){
        move(vec.sub(position));
        return this;
    }
    
    void render(){
        for(Face f: faces){
            f.render();
        }
    }
}
