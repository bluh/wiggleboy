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

V3 top;
V3 right;
V3 mp;

Ray mouseRay;

BaseShape makeCube(float size, V3 position){
    V3[] vs = {
        new V3(0,0,0),
        new V3(0,-size,0),
        new V3(size,-size,0),
        new V3(size,0,0),
        new V3(0,0,size),
        new V3(0,-size,size),
        new V3(size,-size,size),
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

void setup(){
    size(800,600,P3D);
    float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
    perspective(angle, (float) width / height, cameraZ/20.0, cameraZ*10.0);
    subject = new V3();
    shapes = new ArrayList<BaseShape>();
    verts = new ArrayList<V3>();
    top = new V3();
    right = new V3();
    shapes.add(makeCube(50, new V3(0,0,0)));
//    shapes.add(makeCube(30, new V3(0,-60,0)));
    camx = -height/4;
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
    zoom = max(0,zoom + evt.getCount());
}


void mousePressed(){
    V3 offset = new V3();
    if(mouseButton == LEFT){
        offset.set(0,-5,0);
    }else if(mouseButton == RIGHT){
        offset.set(0,5,0);
    }
    if(selectionMode == 0){
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
            pointSelected.move(offset);
        }
    }else if(selectionMode == 1){
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
            lineSelected.point1.move(offset);
            lineSelected.point2.move(offset);
        }
    }else if(selectionMode == 2){
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
            for(V3 vert: faceSelected.verticies){
                vert.move(offset);
            }
        }
    }
}

void keyPressed(){
    if(key == 'w'){
        subject.move(0,-5,0);
    }else if(key == 's'){
        subject.move(0,5,0);
    }else if(key == 'f'){
        subject.set(0,0,0);
        camx = -height/4;
        camy = width/4;
        zoom = 12;
    }else if(key == 't'){
        selectionMode = (1 + selectionMode) % 3;
    }
}

void draw(){
    background(50);
    dt = (dt + 10.0/frameRate) % (TWO_PI);
    if(mousePressed && mouseButton == RIGHT){
        cursor(MOVE);
        camx = min(max(camx - (mouseY - pmouseY), (-height / 2) + 1), (height / 2) - 1);
        camy -= mouseX - pmouseX;
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
        subject.x, subject.y, subject.z, 0, 1, 0
    );
    
    V3 camAbs = cam.sub(subject);
    right = camAbs.cross(0,-5,0).unit().mult(tan(angle/2.0) * camAbs.mag() * (float) width / height).add(subject);
    top = camAbs.cross(right.sub(subject)).unit().mult(tan(angle/2.0) * -camAbs.mag()).add(subject);
    float mx = (2.0 * (width/2 - mouseX)/width) * tan(angle/2.0) * -camAbs.mag() * (float) width / height;
    float my = (2.0 * (height/2 - mouseY)/height) * tan(angle/2.0) * camAbs.mag();
    mp = (right.sub(subject).unit().mult(mx).add(top.sub(subject).unit().mult(my)).add(subject));
    
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
}
