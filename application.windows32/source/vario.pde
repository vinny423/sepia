class Vario{
  float x, y;
  
  int varioWidth = 350;
  float varioInsideScale = 0.95;
  float varioInsideWidth = varioWidth*varioInsideScale;
  
  int smallLineLength = 23;
  int smallLineWidth = 2;
  
  int bigLineLength = 30;
  int bigLineWidth = 3;
  
  int textSize = 25;
  
  int varioMax = 25;
  int lineStep = 1;
  int textStep = 5;
  
  float varioAngleStart = radians(270);
  float varioAngleSpacing = radians(25);
  float varioAngleStep = (TWO_PI-varioAngleSpacing*2)/(varioMax*2);
  
  float needleScale = 0.80;
  float needleLength = varioInsideWidth/2*needleScale;
  int needleWidth = 10;
  float needleTipLength = 20;
  float needleCornerAngle = 360;
  int needleCacheWidth = 20;
  int needleOffset = 5;
  
  Vario(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  void displayFixed(){
    noStroke();
    
    strokeCap(SQUARE);
    
    //Outter circle
    fill(0);
    ellipse (x,y,varioWidth,varioWidth);
    
    //Inner circle
    strokeWeight(2);
    stroke(255);
    fill(20);
    ellipse (x,y,varioInsideWidth,varioInsideWidth);
    
    
    for(int i=-varioMax; i<=varioMax; i+=lineStep){
      pushMatrix();
      translate(x,y);
      rotate(i*varioAngleStep+varioAngleStart);
      
      stroke(255);
      
      if(i%textStep == 0){
        strokeWeight(bigLineWidth);
        line(0,0-varioInsideWidth/2+bigLineLength,0,0-varioInsideWidth/2);
        
        popMatrix();
        
        fill(255);
        float angle = i*varioAngleStep+varioAngleStart+PI/2;
        textSize(this.textSize);
        textAlign(CENTER,CENTER);
        text(i,x-(varioInsideWidth/2-bigLineLength-this.textSize)*cos(angle),y-(varioInsideWidth/2-bigLineLength-this.textSize)*sin(angle));
        
        pushMatrix();
        translate(x,y);
        rotate(i*varioAngleStep+varioAngleStart);
      } else {
        strokeWeight(smallLineWidth);
        line(0,0-varioInsideWidth/2+smallLineLength,0,0-varioInsideWidth/2);
      }
      popMatrix();
    }
    
    textSize(titleTextSize);
    text("VERTICAL SPEED",x,y-titleTextOffset);
    text("100 ft/min",x,y+titleTextOffset);
  }
  
  void display(float fpm){
    displayFixed();
    
    noStroke();
    pushMatrix();
    translate(x,y);
    rotate(fpm/100*varioAngleStep+varioAngleStart);
    
    //Needle
    rect(-needleWidth/2,needleOffset,needleWidth,-needleLength,0,0,needleCornerAngle,needleCornerAngle);
    triangle(-needleWidth/2,-needleLength*0.995+needleOffset,needleWidth/2,-needleLength*0.995+needleOffset,0,-needleLength-needleTipLength);
    
    popMatrix();
    
    noStroke();
    ellipse(x,y,needleCacheWidth,needleCacheWidth);
  }
}
