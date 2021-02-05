class Tachometer{
  float x, y;
  
  int tachoWidth = 350;
  float tachoInsideScale = 0.95;
  float tachoInsideWidth = tachoWidth*tachoInsideScale;
  
  int smallLineLength = 12;
  int smallLineWidth = 2;
  
  int bigLineLength = 25;
  int bigLineWidth = 5;
  
  int tachoTextOffset = 25;
  int tachoTextSize = 30;
  
  float maxRpm = 35;
  
  float tachoAngleStart = radians(230);
  float tachoAngleSpacing = radians(50);
  float tachoAngleStep;
  
  float needleScale = 0.80;
  float needleLength = tachoInsideWidth/2*needleScale;
  int needleWidth = 10;
  float needleTipLength = 20;
  float needleCornerAngle = 360;
  int needleCacheWidth = 20;
  int needleOffset = 5;
  
  Tachometer(float x, float y){
    this.x = x;
    this.y = y;
    
    tachoAngleStep = (TWO_PI-tachoAngleSpacing*2)/maxRpm;
    
    strokeCap(SQUARE);
  }
  
  void displayFixed(){
    noStroke();
    
    //Outter circle
    fill(0);
    ellipse (x,y,tachoWidth,tachoWidth);
    
    //Inner circle
    strokeWeight(2);
    stroke(255);
    fill(20);
    ellipse (x,y,tachoInsideWidth,tachoInsideWidth);
    
    
    for(int i=0; i<=maxRpm; i++){
      pushMatrix();
      translate(x,y);
      rotate(i*tachoAngleStep+tachoAngleStart);
      
      stroke(255);
      
      if(i%5 == 0){
        strokeWeight(bigLineWidth);
        line(0,0-tachoInsideWidth/2+bigLineLength,0,0-tachoInsideWidth/2);
        
        popMatrix();
        
        fill(255);
        float angle = i*tachoAngleStep+tachoAngleStart+PI/2;
        textSize(tachoTextSize);
        textAlign(CENTER,CENTER);
        text(i,x-(tachoInsideWidth/2-bigLineLength-tachoTextOffset)*cos(angle),y-(tachoInsideWidth/2-bigLineLength-tachoTextOffset)*sin(angle));
        
        pushMatrix();
        translate(x,y);
        rotate(i*tachoAngleStep+tachoAngleStart);
      } else {
        strokeWeight(smallLineWidth);
        line(0,0-tachoInsideWidth/2+smallLineLength,0,0-tachoInsideWidth/2);
      }
      popMatrix();
    }
    
    textSize(titleTextSize);
    text("RPM",x,y+titleTextOffset);
    text("x100",x,y+titleTextOffset*2);
  }
  
  void display(float rpm){
    displayFixed();
    
    noStroke();
    pushMatrix();
    translate(x,y);
    rotate(rpm*tachoAngleStep+tachoAngleStart);
    
    //Needle
    rect(-needleWidth/2,needleOffset,needleWidth,-needleLength,0,0,needleCornerAngle,needleCornerAngle);
    triangle(-needleWidth/2,-needleLength*0.995+needleOffset,needleWidth/2,-needleLength*0.995+needleOffset,0,-needleLength-needleTipLength);
    
    popMatrix();
    
    noStroke();
    ellipse(x,y,needleCacheWidth,needleCacheWidth);
  }
}
