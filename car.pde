Car c;
Control ct;
  
void setup(){
  
  frameRate(60);
  size(1280, 720);
  
  background(255);
  c = new Car(300,200,0,0,0,0,0,0);
  
  // controller
  ct = new Control(0, 0, 0);
}

void draw(){
  background(255);
noFill();
stroke(0, 0, 255);
//ellipse(300, 200, 180, 180);
double[] controls = ct.getControlValues();
c.update(controls[0], controls[1], controls[2]);
c.draw();
  if ((keyPressed == true) && (key == 'r')) {
    c.reset(640,380);
  }
}

class Control {
  int deadzone = 50;
  int halfDeadzone = deadzone/2;
  float halfWidth = width/2;
  float halfHeight = height/2;
  double throttle, brake, steering;
  int xMin, xMax, xCtr, yCtr, yMin, yMax;
  
  Control (float _throttle, float _brake, float _steering) {
    throttle = _throttle;
    brake = _brake;
    steering = _steering;
    xMin = width/2-halfDeadzone;
    yMin = height/2-halfDeadzone;
    xCtr = xMin+halfDeadzone;
    yCtr = yMin+halfDeadzone;
    xMax = xMin + deadzone;
    yMax = yMin + deadzone;
  }
  
  double[] getControlValues() {
    steering = 0.0;
    throttle = 0.0;
    brake = 0.0;
    
    stroke(0,255,0);
    rect(xMin, yMin, deadzone, deadzone);
    if (xMin > mouseX) {
      line(mouseX, yCtr, xMin, yCtr);
      steering = (mouseX - xCtr) / halfWidth;
    } else if (xMax < mouseX) {
      line(mouseX, yCtr, xMax, yCtr);
      steering = (mouseX - xCtr) / halfWidth;
    }
    if (yMin > mouseY) {
      line(xCtr, mouseY, xCtr, yMin);
      throttle = (yCtr - mouseY) / halfHeight;
    } else if (yMax < mouseY) {
      line(xCtr, mouseY, xCtr, yMax);
      brake = (mouseY - yCtr) / halfHeight;
    }

    double[] array = {steering,throttle,brake};
    //println(steering,throttle,brake);
    return array;
  }
}

class Car {
  float x, y, vx, vy, ax, ay, heading, a, v;
  double headingRate;
  float slipAngle;
  
  // Lng = Longitudinal direction
  // Hrz = Horizontal direction (skidding)
  double vehicleALng, vehicleAHrz, vehicleVLng, vehicleVHrz;
  double lastVehicleVHrz;

  float throttle, brake, steering;
  float halfWidth = width/2;
  
  Car (float _x, float _y, float _vehicleVLng, float _vehicleVHrz, float _vehicleALng, float _vehicleAHrz, float _heading, float _headingRate) {
    x = _x;
    y = _y;
    vehicleVLng = _vehicleVLng;
    vehicleVHrz = _vehicleVHrz;
    lastVehicleVHrz = vehicleVHrz;
    vehicleALng = _vehicleALng;
    vehicleAHrz = _vehicleAHrz;
    calcWorldCoordinate();
    heading = _heading;
    headingRate = _headingRate;
  }
  
  void reset(float _x, float _y) {
    x = _x;
    y = _y;
    vehicleVLng = 0;
    vehicleVHrz = 0;
    vehicleALng = 0;
    vehicleAHrz = 0;
    lastVehicleVHrz = 0;
    heading = 0;
    headingRate = 0;
    ax = 0;
    ay = 0;
    vx = 0;
    vy = 0;
    calcWorldCoordinate();
  }
  
  void calcWorldCoordinate() {
    if (slipAngle > 0 || slipAngle < 0) {
      // car can't move horizontally.
      // friction applys to horizontal movement
      vehicleAHrz = -(vehicleVHrz - lastVehicleVHrz)/2;
      lastVehicleVHrz = vehicleVHrz;
    }

    ax = cos((float)heading)*(float)vehicleAHrz + sin((float)heading)*(float)vehicleALng;
    ay = sin((float)heading)*(float)vehicleAHrz - cos((float)heading)*(float)vehicleALng;

    float dx = sin((float)heading)*(float)vehicleVLng;
    float dy = -cos((float)heading)*(float)vehicleVLng;

    vx += ax;
    vy += ay;
    x += vx + dx;
    y += vy + dy;
  }
  
  void update(double steering, double throttle, double brake) {
    headingRate = steering * 0.01;
    heading = (heading + (float)headingRate)%TWO_PI;
    
    //vehicleAHrz = vehicleVLng * steering;
    //println(vehicleAHrz);
    //vehicleVHrz = vehicleVHrz + vehicleAHrz;

    vehicleALng = - (vehicleALng * abs((float)steering));

    double decelerationLng = 0;
    if (vehicleVLng > 0) {
      decelerationLng = decelerationLng + brake * 0.01;
    }
    vehicleALng = throttle * 0.01 - decelerationLng;
    vehicleVLng = vehicleVLng + vehicleALng;

    v = sqrt(pow(vx,2) + pow(vy,2));
    float nx = vx / v;
    float ny = vy / v;
    
    pushMatrix();
    translate(x,y);
    float vectorHdg = (atan2(ny * height,nx * width) + HALF_PI)%TWO_PI;
    popMatrix();

    slipAngle = vectorHdg - heading;

    vehicleVHrz = v * sin(slipAngle);

    calcWorldCoordinate();
    a = sqrt(pow(ax,2) + pow(ay,2));
    v = sqrt(pow(vx,2) + pow(vy,2));
  }
  
  void draw() {
    pushMatrix();
    translate(x, y);
    rotate(heading);
    triangle(10, 0, 5, 25, 15, 25);
    popMatrix();
    
    fill(0,255,0);
    textAlign(LEFT);
    text("aL", halfWidth-100, height-15); // vehicle longitudinal acceleration
    text("aH", halfWidth-100, height-5); // vehicle horizontal acceleration
    text("vL", halfWidth-40, height-15); // vehicle longitudinal velocity
    text("vH", halfWidth-40, height-5); // vehicle horizontal velocity
    text("HDG", halfWidth+20, height-15); // vehicle heading
    text("HDGRate", halfWidth+20, height-5); // vehicle heading turn rate

    textAlign(RIGHT);
    text((float)vehicleALng, halfWidth-45, height-15);
    text((float)vehicleAHrz, halfWidth-45, height-5);
    text((float)vehicleVLng, halfWidth+15, height-15);
    text((float)vehicleVHrz, halfWidth+15, height-5);
    text(heading, halfWidth+110, height-15);
    text((float)headingRate, halfWidth+110, height-5);
    
    text(a, halfWidth-15, height-30);
    text(v, halfWidth+25, height-30);
  }
}
