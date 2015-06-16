class V3{
    float x;
    float y;
    float z;
    String name;
    
    V3(){
        this(0.0,0.0,0.0);
    }
    
    V3(float x, float y, float z){
        set(x,y,z);
    }
    
    V3(V3 ref){
        set(ref.x,ref.y,ref.z);
    }
    
    void setName(String name){
        this.name = name;
    }
    
    V3 move(V3 amt){
        this.x += amt.x;
        this.y += amt.y;
        this.z += amt.z;
        return this;
    }
    
    V3 move(float x, float y, float z){
        this.x += x;
        this.y += y;
        this.z += z;
        return this;
    }
    
    V3 set(float x, float y, float z){
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }
    
    V3 add(V3 vec){
        return new V3(this.x + vec.x, this.y + vec.y, this.z + vec.z);
    }
    
    V3 add(float x, float y, float z){
        return new V3(this.x + x, this.y + y, this.z + z);
    }
    
    V3 sub(V3 vec){
        return new V3(this.x - vec.x, this.y - vec.y, this.z - vec.z);
    }
    
    V3 sub(float x, float y, float z){
        return new V3(this.x - x, this.y - y, this.z - z);
    }
    
    V3 mult(V3 vec){
        return new V3(this.x * vec.x, this.y * vec.y, this.z * vec.z);
    }
    
    V3 mult(float x, float y, float z){
        return new V3(this.x * x, this.y * y, this.z * z);
    }
    
    V3 mult(float i){
        return new V3(this.x * i, this.y * i, this.z * i);
    }
    
    float mag(){
        return sqrt(x * x + y * y + z * z);
    }
    
    V3 unit(){
        if(this.mag() > 0){
            return this.mult(1.0/this.mag());
        }else{
            return new V3();
        }
    }
    
    float dot(V3 ref){
        return this.x * ref.x + this.y * ref.y + this.z * ref.z;
    }
    
    float dot(float x, float y, float z){
        return this.x * x + this.y * y + this.z * z;
    }
    
    V3 cross(V3 ref){
        return new V3(
            this.y * ref.z - ref.y * this.z,
            this.z * ref.x - ref.z * this.x,
            this.x * ref.y - ref.x * this.y
        );
    }
    
    V3 cross(float x, float y, float z){
        return new V3(
            this.y * z - y * this.z,
            this.z * x - z * this.x,
            this.x * y - x * this.y
        );
    }
    
    V3 neg(){
        return new V3(-x,-y,-z);
    }
    
    void visualize(){
        translate(x,y,z);
        sphere(5);
//        text(this.toString(),0,0,0);
        translate(-x,-y,-z);
    }
    
    String toString(){
        return "("+x+", "+y+", "+z+")";
        if(this.name != null){
            return this.name;
        }else{
            return "("+x+", "+y+", "+z+")";
        }
    }
}
