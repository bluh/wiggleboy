BaseShape b;
ArrayList<BaseShape> shapes;
ArrayList<V3> verts;
V3 subject;
V3 cam;
float camx;
float camy;
float angle = PI/3.0;
float zoom = 12;
float dt;

int selectionMode = 0; //0 == point, 1 == line, 2 == face
int movement = 5;
int movX = 0;
int movY = 0;
int movZ = 0;

V3 top;
V3 right;
V3 mp;

V3 mpDown;
Object selectedObj;

Ray mouseRay;

BaseShape makeCube(float size, V3 position){
    V3[] vs = {
        new V3(0,0,0),
        new V3(0,size,0),
        new V3(size,size,0),
        new V3(size,0,0),
        new V3(0,0,size),
        new V3(0,size,size),
        new V3(size,size,size),
        new V3(size,0,size)
    };
    Line[] lines = {
        new Line(vs[0], vs[1]),
        new Line(vs[1], vs[2]),
        new Line(vs[2], vs[3]),
        new Line(vs[3], vs[0]),
        new Line(vs[4], vs[5]),
        new Line(vs[5], vs[6]),
        new Line(vs[6], vs[7]),
        new Line(vs[7], vs[4]),
        new Line(vs[3], vs[7]),
        new Line(vs[2], vs[6]),
        new Line(vs[0], vs[4]),
        new Line(vs[1], vs[5])
    };
    Line[][] faceData = {
        {lines[0], lines[1], lines[2], lines[3]},
        {lines[4], lines[5], lines[6], lines[7]},
        {lines[0], lines[11], lines[4], lines[10]},
        {lines[2], lines[8], lines[6], lines[9]}, //error
        {lines[1], lines[9], lines[5], lines[11]},
        {lines[3], lines[10], lines[7], lines[8]}
    };
    for(V3 vert: vs){
        vert.move(-size/2,0,-size/2);
    }
    return new BaseShape(vs, lines, faceData, position);
}

BaseShape makePyramid(float size, float pHeight, V3 position){
    V3[] vecs = {
        new V3(0,0,size),
        new V3(size,0,size),
        new V3(size,0,0),
        new V3(0,0,0),
        new V3(size/2,pHeight,size/2)
    };
    Line[] lines = {
        new Line(vecs[0],vecs[1]),
        new Line(vecs[1],vecs[2]),
        new Line(vecs[2],vecs[3]),
        new Line(vecs[3],vecs[0]), //3
        new Line(vecs[0],vecs[4]), //4
        new Line(vecs[1],vecs[4]),
        new Line(vecs[2],vecs[4]),
        new Line(vecs[3],vecs[4])
    };
    Line[][] faceData = {
        {lines[0],lines[1],lines[2],lines[3]},
        {lines[0],lines[4],lines[5]},
        {lines[1],lines[5],lines[6]},
        {lines[2],lines[6],lines[7]},
        {lines[3],lines[7],lines[4]}
    };
    for(V3 vert: vecs){
        vert.move(-size/2,0,-size/2);
    }
    return new BaseShape(vecs, lines, faceData, position);
}

BaseShape loadShape(String v, float size, V3 position){
    String[] strings = loadStrings(v);
    if(strings == null){
        println("File does not exist.");
        return null;
    }
    ArrayList<V3> vecs = new ArrayList();
    ArrayList<Line> lines = new ArrayList();
    ArrayList<Line[]> faceData = new ArrayList();
    int count = 0;
    V3 center = null;
    println("Reading file...");
    for(String l: strings){
        if(l.indexOf("v") == 0){
            String[] data = (l.substring(1)).split(" ");
            float x = float(data[data.length-3]);
            float y = float(data[data.length-2]);
            float z = float(data[data.length-1]);
            x = x * size;
            y = y * size;
            z = z * size;
            V3 n = new V3(x,y,z);
            if(center == null){
                center = n.mult(1);
                println("New vert[" + vecs.size() + "] = " + n);
            }
            n.moveNeg(center);
            vecs.add(n);
        }else if(l.indexOf("f") == 0 && ++count < 10000){
            String[] data = (l.substring(1)).split(" ");
            int v1 = int(data[data.length - 3]) - 1;
            int v2 = int(data[data.length - 2]) - 1;
            int v3 = int(data[data.length - 1]) - 1;
            V3 a = vecs.get(v1);
            V3 b = vecs.get(v2);
            V3 c = vecs.get(v3);
            Line line1 = new Line(a,b);
            int act1 = lines.indexOf(line1);
            println("A1 : " + act1);
            if(act1 == -1){
                println("Adding new line between [" + v1 + "] " + a + " & [" + v2 + "] " + b + " to the array.");
                lines.add(line1);
            }else{
                println("Referencing old line...");
                line1 = lines.get(act1);
            }
            Line line2 = new Line(b,c);
            int act2 = lines.indexOf(line2);
            println("A2 : " + act2);
            if(act2 == -1){
                println("Adding new line between [" + v2 + "] " + b + " & [" + v3 + "] " + c + " to the array.");
                lines.add(line2);
            }else{
                println("Referencing old line...");
                line2 = lines.get(act2);
            }
            Line line3 = new Line(a,c);
            int act3 = lines.indexOf(line3);
            println("A3 : " + act3);
            if(act3 == -1){
                println("Adding new line between [" + v1 + "] " + a + " & [" + v3 + "] " + c + " to the array.");
                lines.add(line3);
            }else{
                println("Referencing old line...");
                line3 = lines.get(act3);
            }
            Line[] lineData = {line1, line2, line3};
            println("Adding new face to table.");
            faceData.add(lineData);
        }   
    }
    println("Compiling data...");
    return new BaseShape(vecs, lines, faceData, position);
}

void setup(){
    size(800,600,P3D);
    surface.setResizable(true);
    float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
    perspective(angle, (float) width / height, cameraZ/20.0, cameraZ*10.0);
    subject = new V3();
    shapes = new ArrayList<BaseShape>();
    verts = new ArrayList<V3>();
    top = new V3();
    right = new V3();
    //shapes.add(makeCube(50, new V3(0,0,0)));
    //shapes.add(makePyramid(50, 50, new V3(0,60,0)));
    shapes.add(loadShape("objects/teapot.obj", 10, new V3(0,-30,0)));
    camx = height/4;
    camy = width/4;
    cam = new V3(
        (100 + zoom * 25) * sin(camy * PI / height) * cos(camx * PI / height) + subject.x,
        (100 + zoom * 25) * sin(camx * PI / height) + subject.y,
        (100 + zoom * 25) * cos(camy * PI / height) * cos(camx * PI / height) + subject.z
    );
    mouseRay = new Ray(cam, subject);
    sphereDetail(5,3);
}

void mouseWheel(MouseEvent evt){
    zoom = max(0,zoom - evt.getCount());
}

void mousePressed(){
    if(mouseButton == LEFT){
        if(selectedObj == null && selectionMode == 0){
            V3 pointSelected = null;
            for(BaseShape b: shapes){
                for(V3 v: b.verticies){
                    if(mouseRay.distanceToPoint(v) <= 10){
                        if(pointSelected == null){
                            pointSelected = v;
                        }else{
                            if(cam.sub(v).mag() < cam.sub(pointSelected).mag()){
                                pointSelected = v;
                            }
                        }
                    }
                }
            }
            if(pointSelected != null){
                selectedObj = pointSelected;
                mpDown = new V3(mp);
            }
        }else if(selectedObj == null && selectionMode == 1){
            Line lineSelected = null;
            for(BaseShape b: shapes){
                for(Line line: b.lines){
                    float[] res = mouseRay.connectToLine(line.point1, line.point2.sub(line.point1).unit());
                    if(res[1] >= 0 && res[1] <= line.point2.sub(line.point1).mag()){
                        V3 p1 = mouseRay.start.add(mouseRay.unit.mult(res[0]));
                        V3 p2 = line.point1.add(line.point2.sub(line.point1).unit().mult(res[1]));
                        float dist = p2.sub(p1).mag();
                        if(dist <= 5){
                            if(lineSelected == null){
                                lineSelected = line;
                            }else{
                                if(cam.sub(line.point1.add(line.point2).mult(.5)).mag() < cam.sub(lineSelected.point1.add(lineSelected.point2).mult(.5)).mag()){
                                   lineSelected = line;
                                }
                            }
                        }
                    }
                }
            }
            if(lineSelected != null){
                selectedObj = lineSelected;
                mpDown = new V3(mp);
            }
        }else if(selectedObj == null && selectionMode == 2){
            Face faceSelected = null;
            for(BaseShape b: shapes){
                for(Face face: b.faces){
                    if(mouseRay.intersectsFace(face)){
                        if(faceSelected == null){
                            faceSelected = face;
                        }else{
                            if(faceSelected.getCenter().sub(cam).mag() > face.getCenter().sub(cam).mag()){
                                faceSelected = face;
                            }
                        }
                    }
                }           
            }
            if(faceSelected != null){
                selectedObj = faceSelected;
                mpDown = new V3(mp);
            }
        }
    }
}

void mouseReleased(){
    selectedObj = null;
    mpDown = null;
}

void keyPressed(){
    if(key == CODED){
        if(keyCode == SHIFT){
            movement *= 2.5;
        }
    }else if(key == 'e'){
        movY += 1;
    }else if(key == 'q'){
        movY -= 1;
    }else if(key == 'w'){
        movZ -= 1;
    }else if(key == 's'){
        movZ += 1;
    }else if(key == 'a'){
        movX -= 1;
    }else if(key == 'd'){
        movX += 1;
    }else if(key == 'f'){
        subject.set(0,0,0);
        camx = height/4;
        camy = width/4;
        zoom = 12;
    }else if(key == 't'){
        selectionMode = (1 + selectionMode) % 3;
    }
}

void keyReleased(){
    if(key == CODED){
        if(keyCode == SHIFT){
            movement /= 2.5;
        }
    }else if(key == 'e'){
        movY -= 1;
    }else if(key == 'q'){
        movY += 1;
    }else if(key == 'w'){
        movZ += 1;
    }else if(key == 's'){
        movZ -= 1;
    }else if(key == 'a'){
        movX += 1;
    }else if(key == 'd'){
        movX -= 1;
    }
}

void updateSelected(){
    V3 delta = mp.sub(mpDown);
    if(selectedObj instanceof V3){
        ((V3) selectedObj).move(delta);
    }else if(selectedObj instanceof Line){
        ((Line) selectedObj).point1.move(delta);
        ((Line) selectedObj).point2.move(delta);
    }else if(selectedObj instanceof Face){
        for(V3 p: ((Face)selectedObj).verticies){
            p.move(delta);
        }
    }
    mpDown = new V3(mp);
}

void draw(){
    background(50);
    camera();
    dt = (dt + 10.0/frameRate) % (TWO_PI);
    
    //update selected object
    if(selectedObj != null){
        updateSelected();
    }
    
    //move subject
    if(movY != 0){
        subject.move(top.sub(subject).unit().mult(movement * movY));
    }
    if(movX != 0){
        subject.move(right.sub(subject).unit().mult(movement * movX));
    }
    if(movZ != 0){
        subject.move(cam.sub(subject).unit().mult(movement * movZ));
    }   
    
    //camera code
    if(mousePressed && mouseButton == RIGHT){
        cursor(MOVE);
        camx = min(max(camx - (pmouseY - mouseY), (-height / 2) + 1), (height / 2) - 1);
        camy += mouseX - pmouseX;
    }else{
        cursor(ARROW);
    }
    cam.set(
        (100 + zoom * 25) * sin(camy * PI / height) * cos(camx * PI / height) + subject.x,
        (100 + zoom * 25) * sin(camx * PI / height) + subject.y,
        (100 + zoom * 25) * cos(camy * PI / height) * cos(camx * PI / height) + subject.z
    );
    camera(
        cam.x, cam.y, cam.z,
        subject.x, subject.y, subject.z, 0, -1, 0
    );
    
    //camera variables
    V3 camAbs = cam.sub(subject);
    right = camAbs.cross(0,-5,0).unit().mult(tan(angle/2.0) * -camAbs.mag() * (float) width / height).add(subject);
    top = camAbs.cross(right.sub(subject)).unit().mult(tan(angle/2.0) * -camAbs.mag()).add(subject);
    float mx = (2.0 * (width/2 - mouseX)/width) * tan(angle/2.0) * -camAbs.mag() * (float) width / height;
    float my = (2.0 * (height/2 - mouseY)/height) * tan(angle/2.0) * camAbs.mag();
    mp = (right.sub(subject).unit().mult(mx).add(top.sub(subject).unit().mult(my)).add(subject));
    
    //right.visualize();
    //top.visualize();
    //mp.visualize();
    
    strokeWeight(3);
    stroke(255,0,0); //red = x
    line(subject.x, subject.y, subject.z, subject.x + 50, subject.y, subject.z);
    stroke(0,255,0); //green = y
    line(subject.x, subject.y, subject.z, subject.x, subject.y + 50, subject.z);
    stroke(0,0,255); //blue = z
    line(subject.x, subject.y, subject.z, subject.x, subject.y, subject.z + 50);
    strokeWeight(1);
    stroke(0,0,0);
    
    for(int x = -10; x <= 10; x++){
        line(x * 50,0,-500,x * 50, 0 ,500);
    }
    for(int y = -10; y <= 10; y++){
        line(-500,0,y * 50,500, 0 ,y * 50);
    }
    
    for(V3 v: verts){
        v.visualize();
    }
    
    mouseRay.set(cam, mp);
    for(BaseShape b: shapes){
        if(selectionMode == 0){
            stroke(0,0,0);
            for(V3 v: b.verticies){
                if(mouseRay.distanceToPoint(v) <= 10){
                    fill(255, 255, 75 + 75 * sin(dt));
                }else{
                    fill(255, 255, 255);
                }
                v.visualize();
            }
        }
        for(Line line: b.lines){
            stroke(0,0,0);
            strokeWeight(1);
            if(selectionMode == 1){
                strokeWeight(3);
                float[] res = mouseRay.connectToLine(line.point1, line.point2.sub(line.point1).unit());
                if(res[1] > 0 && res[1] < line.point2.sub(line.point1).mag()){
                    V3 p1 = mouseRay.start.add(mouseRay.unit.mult(res[0]));
                    V3 p2 = line.point1.add(line.point2.sub(line.point1).unit().mult(res[1]));
                    float dist = p2.sub(p1).mag();
                    if(dist <= 5){
                        stroke(255, 255, 75 + 75 * sin(dt));
                    }
                }
            }
            line.render();
        }
        for(Face face: b.faces){
            fill(255, 255, 255, 100);
            if(selectionMode == 2 && mouseRay.intersectsFace(face)){
                fill(255, 255, 25 + 25 * sin(dt), 100);
            }
            face.render();
        }
    }
    
    camera();
    hint(DISABLE_DEPTH_TEST);
    text("hello",100,100);
    hint(ENABLE_DEPTH_TEST);
}
