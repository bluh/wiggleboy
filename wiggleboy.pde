BaseShape b;
ArrayList<BaseShape> shapes;
ArrayList<V3> vecs;
V3 subject;
V3 cam;
float camx;
float camy;
float angle = PI/3.0;
float zoom = 12;
float cameraZ;

V3 top;
V3 bottom;
V3 right;
V3 left;
V3 mp;

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
  V3[][] details = {
    {vs[0], vs[1], vs[2], vs[3]},
    {vs[4], vs[5], vs[6], vs[7]},
    {vs[2], vs[3], vs[7], vs[6]},
    {vs[0], vs[1], vs[5], vs[4]},
    {vs[1], vs[2], vs[6], vs[5]},
    {vs[0], vs[3], vs[7], vs[4]}
  };
  for(V3 vert: vs){
    vert.move(-size/2,0,-size/2);
    vecs.add(vert);
  }
  return new BaseShape(vs, details, position);
}

void setup(){
  size(500,500,P3D);
  cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
  perspective(PI/3.0, width/height, cameraZ/20.0, cameraZ*10.0);
  subject = new V3();
  shapes = new ArrayList<BaseShape>();
  vecs = new ArrayList<V3>();
  top = new V3();
  bottom = new V3();
  left = new V3();
  right = new V3();
  shapes.add(makeCube(50, new V3(0,-10,0)));
//  shapes.add(makeCube(30, new V3(0,-60,0)));
  camx = -height/4;
  camy = width/4;
  cam = new V3(
    (100 + zoom * 25) * sin(camy * PI / height) * cos(camx * PI / height) + subject.x,
    (100 + zoom * 25) * sin(camx * PI / height) + subject.y,
    (100 + zoom * 25) * cos(camy * PI / height) * cos(camx * PI / height) + subject.z
  );
  sphereDetail(5,3);
}

void mouseWheel(MouseEvent evt){
  zoom = max(0,zoom + evt.getCount());
}

void mouseClicked(){
  vecs.add(new V3(cam));
  vecs.add(new V3(top));
  vecs.add(new V3(bottom));
  vecs.add(new V3(right));
  vecs.add(new V3(left));
  vecs.add(new V3(subject));
  vecs.add(new V3(mp));
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
  }
}


float x;

void draw(){
  background(50);
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
  right = cam.sub(subject).cross(0,-5,0).unit().mult(tan(angle/2.0) * (cam.sub(subject)).mag()).add(subject);
  left = cam.sub(subject).cross(0,-5,0).unit().mult(-tan(angle/2.0) * (cam.sub(subject)).mag()).add(subject);
  top = cam.sub(subject).cross(left.sub(subject)).unit().mult(tan(angle/2.0) * cam.sub(subject).mag()).add(subject);
  bottom = cam.sub(subject).cross(right.sub(subject)).unit().mult(tan(angle/2.0) * cam.sub(subject).mag()).add(subject);
  top.visualize();
  bottom.visualize();
  left.visualize();
  right.visualize();
  float mx = (2.0 * (width/2 - mouseX)/width) * tan(angle/2.0) * -cam.sub(subject).mag();
  float my = (2.0 * (height/2 - mouseY)/height) * tan(angle/2.0) * cam.sub(subject).mag();
  mp = (right.sub(subject).unit().mult(mx).add(top.sub(subject).unit().mult(my)).add(subject));
  mp.visualize();
  strokeWeight(3);
  stroke(255,0,0);
  line(subject.x, subject.y, subject.z, subject.x + 50, subject.y, subject.z);
  stroke(0,255,0);
  line(subject.x, subject.y, subject.z, subject.x, subject.y + 50, subject.z);
  stroke(0,0,255);
  line(subject.x, subject.y, subject.z, subject.x, subject.y, subject.z + 50);
  strokeWeight(1);
  stroke(0,0,0);
  for(V3 v: vecs){
    v.visualize();
  }
  for(int x = -10; x <= 10; x++){
    line(x * 50,0,-500,x * 50, 0 ,500);
  }
  for(int y = -10; y <= 10; y++){
    line(-500,0,y * 50,500, 0 ,y * 50);
  }
  for(BaseShape b: shapes){
    b.render();
  }
}
