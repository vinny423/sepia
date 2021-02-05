class Airspeed{
  float x, y;
  
  int airspeedWidth = 350;
  float airspeedInsideScale = 0.95;
  float airspeedInsideWidth = airspeedWidth*airspeedInsideScale;
  
  int smallLineLength = 23;
  int smallLineWidth = 2;
  
  int bigLineLength = 30;
  int bigLineWidth = 3;
  
  int textSize = 20;
  
  int maxSpeed = 160;
  int startSpeed = 40;
  int lineStep = 2;
  int textStep = 10;
  
  float airspeedAngleStart = radians(200);
  float airspeedAngleSpacing = radians(30);
  float airspeedAngleStep = (TWO_PI-airspeedAngleSpacing*2)/(maxSpeed-startSpeed);
  
  float needleScale = 0.80;
  float needleLength = airspeedInsideWidth/2*needleScale;
  int needleWidth = 10;
  float needleTipLength = 20;
  float needleCornerAngle = 360;
  int needleCacheWidth = 20;
  int needleOffset = 5;
  
  Airspeed(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  void displayFixed(){
    noStroke();
    
    strokeCap(SQUARE);
    textSize(textSize);
    textAlign(CENTER,CENTER);
    
    //Outter circle
    fill(0);
    ellipse (x,y,airspeedWidth,airspeedWidth);
    
    //Inner circle
    strokeWeight(2);
    stroke(255);
    fill(20);
    ellipse (x,y,airspeedInsideWidth,airspeedInsideWidth);
    
    
    for(int i=startSpeed; i<=maxSpeed; i+=lineStep){
      pushMatrix();
      translate(x,y);
      rotate((i-startSpeed)*airspeedAngleStep+airspeedAngleStart);
      
      stroke(255);
      
      if(i%textStep == 0){
        strokeWeight(bigLineWidth);
        line(0,0-airspeedInsideWidth/2+bigLineLength,0,0-airspeedInsideWidth/2);
        
        popMatrix();
        
        fill(255);
        float angle = (i-startSpeed)*airspeedAngleStep+airspeedAngleStart+PI/2;
        text(i,x-(airspeedInsideWidth/2-bigLineLength-textSize)*cos(angle),y-(airspeedInsideWidth/2-bigLineLength-textSize)*sin(angle));
        
        pushMatrix();
        translate(x,y);
        rotate(i*airspeedAngleStep+airspeedAngleStart);
      } else {
        strokeWeight(smallLineWidth);
        line(0,0-airspeedInsideWidth/2+smallLineLength,0,0-airspeedInsideWidth/2);
      }
      popMatrix();
    }
    
    textSize(titleTextSize);
    text("AIRSPEED",x,y-titleTextOffset);
    text("KNOTS",x,y+titleTextOffset);
  }
  
  void display(float speed){
    displayFixed();
    
    noStroke();
    pushMatrix();
    translate(x,y);
    rotate((speed-startSpeed)*airspeedAngleStep+airspeedAngleStart);
    
    //Needle
    rect(-needleWidth/2,needleOffset,needleWidth,-needleLength,0,0,needleCornerAngle,needleCornerAngle);
    triangle(-needleWidth/2,-needleLength*0.995+needleOffset,needleWidth/2,-needleLength*0.995+needleOffset,0,-needleLength-needleTipLength);
    
    popMatrix();
    
    noStroke();
    ellipse(x,y,needleCacheWidth,needleCacheWidth);
  }
}
