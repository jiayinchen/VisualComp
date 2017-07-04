class Sphere {
  float radius = 14;
  PVector location;
  PVector velocity;
  double v = 0;
  PVector gravityForce;
  float gravityConstant = 0.1;
  float groundHeight = radius+boxHeight/2;
  float normalForce = 1;
  float mu = 0.01;
  float frictionMagnitude = normalForce * mu;

  Sphere() {
    location = new PVector(0, -groundHeight, 0);
    velocity = new PVector(0, 0, 0);
    gravityForce = new PVector(0, 0, 0);
  }

  void update() {
    gravityForce.x = sin(rz) * gravityConstant;
    gravityForce.z = sin(rx) * gravityConstant;
    PVector friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    velocity.add(gravityForce);
    velocity.add(friction);
    location.add(velocity);
    v = Math.pow(Math.pow(velocity.x,2) + Math.pow(velocity.z,2), 0.5);
    if(v < 0.1) v = 0;
  }

  void display() {
    pushMatrix();
    if (!shiftMode) {
      translate(location.x, location.y, location.z);
    } else {
      translate(location.x, location.z, 0);
    }
    sphere(radius);
    popMatrix();
  }

  void checkEdges() {
    int isE=0;
    if (location.y > -groundHeight) {
      location.y = -groundHeight;
      
      if(isOutside==false){
        score -= v;
        scores.add(score);
      }
      scoreChange = -v;
      isE++;
    }
    if (location.x > boxWidth/2) {
      location.x = boxWidth/2;
      velocity.x = -velocity.x;
      
      if(isOutside==false){
        score -= v;
        scores.add(score);
      }
      scoreChange = -v;
      isE++;
    }
    if (location.x < -boxWidth/2) {
      location.x = -boxWidth/2;
      velocity.x = -velocity.x;
      if(isOutside==false){
        score -= v;
        scores.add(score);
      }
      scoreChange = -v;
      isE++;
    }
    if (location.z > boxWidth/2) {
      location.z = boxWidth/2;
      velocity.z = -velocity.z;
      if(isOutside==false){
        score -= v;
        scores.add(score);
      }
      scoreChange = -v;
      isE++;
    }
    if (location.z < -boxWidth/2) {
      location.z = -boxWidth/2;
      velocity.z = -velocity.z;
      if(isOutside==false){
        score -= v;
        scores.add(score);
      }
      scoreChange = -v;
      isE++;
    }
    if(isE>0){
      isOutside=true;
    }
    else{
      isOutside=false;
    }
  }
  
    
  void checkCylinderCollision(){
    for(int i = 0; i<cylinders.size(); i++){
      double dist = Math.pow(Math.pow(location.x - cylinders.get(i).getPosition().x,2) + Math.pow(location.z - cylinders.get(i).getPosition().z,2), 0.5);
      if(dist < radius + cylinderBaseSize){
        //collision
        scoreChange = v;
        score +=v;
        scores.add(score);
        PVector n = new PVector(location.x - cylinders.get(i).getPosition().x, 0, location.z - cylinders.get(i).getPosition().z);
        n = n.normalize();
        location.x = cylinders.get(i).getPosition().x + n.x*(radius + cylinderBaseSize);
        location.z = cylinders.get(i).getPosition().z + n.z*(radius + cylinderBaseSize);
        PVector V2 = velocity.sub(n.mult(2*(velocity.dot(n))));
        velocity = V2;
      }
    }
  }
}