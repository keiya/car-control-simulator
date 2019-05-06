Car c;
Control ct;
  
void setup(){
  
  frameRate(60);
  size(600, 400);
  
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
float[] controls = ct.getControlValues();
c.update(controls[0], controls[1], controls[2]);
c.draw();

}

class Control {
  int deadzone = 50;
  int halfDeadzone = deadzone/2;
  float halfWidth = width/2;
  float halfHeight = height/2;
  float throttle, brake, steering;
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
  
  float[] getControlValues() {
    steering = 0.0;
    throttle = 0.0;
    brake = 0.0;
    
    stroke(0,255,0);
    rect(xMin, yMin, deadzone, deadzone);
    if (xMin > mouseX) {
      line(mouseX, yCtr, xMin, yCtr);
    } else if (xMax < mouseX) {
      line(mouseX, yCtr, xMax, yCtr);
    }
    if (yMin > mouseY) {
      line(xCtr, mouseY, xCtr, yMin);
      throttle = (yCtr - mouseY) / halfHeight;
    } else if (yMax < mouseY) {
      line(xCtr, mouseY, xCtr, yMax);
      brake = (mouseY - yCtr) / halfHeight;
    }

    steering = (mouseX - xCtr) / halfWidth;
    
    float[] array = {steering,throttle,brake};
    //println(steering,throttle,brake);
    return array;
  }
}

class Car {
  float x, y, vx, vy, ax, ay, heading, headingRate, a, v;
  
  // Lng = Longitudinal direction
  // Hrz = Horizontal direction (skidding)
  float vehicleALng, vehicleAHrz, vehicleVLng, vehicleVHrz;
  
  float throttle, brake, steering;
  float halfWidth = width/2;
  
  Car (float _x, float _y, float _vehicleVLng, float _vehicleVHrz, float _vehicleALng, float _vehicleAHrz, float _heading, float _headingRate) {
    x = _x;
    y = _y;
    vehicleVLng = _vehicleVLng;
    vehicleVHrz = _vehicleVHrz;
    vehicleALng = _vehicleALng;
    vehicleAHrz = _vehicleAHrz;
    calcWorldCoordinate();
    heading = _heading;
    headingRate = _headingRate;
  }
  
  void calcWorldCoordinate() {
    ay = sin(heading)*vehicleAHrz - cos(heading)*vehicleALng;
    ax = cos(heading)*vehicleAHrz + sin(heading)*vehicleALng;
    vx = vx + ax;
    vy = vy + ay;
    x = x + vx;
    y = y + vy;
  }
  
  void update(float steering, float throttle, float brake) {
    headingRate = steering * 0.01;
    heading = (heading + headingRate)%TWO_PI;
    
    float decelerationLng = 0;
    if (vehicleVLng > 0) {
      decelerationLng = brake * 0.01;
    }
    vehicleALng = throttle * 0.01 - decelerationLng;
    vehicleVLng = vehicleVLng + vehicleALng;

    println(vehicleVLng);
    calcWorldCoordinate();
    a = sqrt(pow(ax,2) + pow(ay,2));
    v = sqrt(pow(vx,2) + pow(vy,2));

    heading = heading + headingRate;
  }
  
  void draw() {
    pushMatrix();
    translate(x, y);
    rotate(heading);
    triangle(10, 0, 5, 25, 15, 25);
    popMatrix();
    
    fill(0,255,0);
    textAlign(LEFT);
    text("ax", halfWidth-100, height-15);
    text("ay", halfWidth-100, height-5);
    text("vx", halfWidth-40, height-15);
    text("vy", halfWidth-40, height-5);
    text("HDG", halfWidth+20, height-15);
    text("HDGRate", halfWidth+20, height-5);

    textAlign(RIGHT);
    text(ax, halfWidth-45, height-15);
    text(ay, halfWidth-45, height-5);
    text(vx, halfWidth+15, height-15);
    text(vy, halfWidth+15, height-5);
    text(heading, halfWidth+110, height-15);
    text(headingRate, halfWidth+110, height-5);
    
    text(a, halfWidth-15, height-30);
    text(v, halfWidth+25, height-30);
  }
}
