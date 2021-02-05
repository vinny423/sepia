class Altimeter{
  float x, y;
  
  int altimeterWidth = 350;
  float altimeterInsideScale = 0.95;
  float altimeterInsideWidth = altimeterWidth*altimeterInsideScale;
  
  float smallLineLength = 12;
  float smallLineWidth = 2;
  
  float bigLineLength = 25;
  float bigLineWidth = 4;
  
  float altimeterTextOffset = 25;
  float altimeterTextSize = 40;
  float altimeterCounterTextSize = 30;
  
  float altimeterAngleStep = radians(7.2);
  
  float thousandsNeedleScale = 0.6;
  float thousandsNeedleLength = altimeterInsideWidth/2*thousandsNeedleScale;
  float thousandsNeedleWidth = 15;
  
  float hundredsNeedleScale = 0.85;
  float hundredsNeedleLength = altimeterInsideWidth/2*hundredsNeedleScale;
  float hundredsNeedleWidth = 10;
  
  float needleTipLength = 20;
  float needleCornerAngle = 360;
  float needleCacheWidth = 20;
  float needleOffset = 0.55;
  
  float quadrantOffset = altimeterWidth/7.143;
  float quadrantWidth = altimeterWidth/2.5;
  float quadrantHeight = altimeterWidth/9.1;
  float quadrantLineWidth = 3;
  
  Altimeter(float x, float y){
    this.x = x;
    this.y = y;
    
    strokeCap(SQUARE);
    textAlign(CENTER,CENTER);
  }
  
  void displayFixed(){
    textSize(altimeterTextSize);
    noStroke();
    fill(0);
    ellipse (x,y,altimeterWidth,altimeterWidth);
    
    strokeWeight(2);
    stroke(255);
    fill(20);
    ellipse (x,y,altimeterInsideWidth,altimeterInsideWidth);
    
    for(int i=0; i<50; i++){
      pushMatrix();
      translate(x,y);
      rotate(i*altimeterAngleStep);
      
      stroke(255);
      
      if(i%5 == 0){
        strokeWeight(bigLineWidth);
        line(0,0-altimeterInsideWidth/2+bigLineLength,0,0-altimeterInsideWidth/2);
        
        popMatrix();
        
        fill(255);
        text(i*1/5,x-(altimeterInsideWidth/2-bigLineLength-altimeterTextOffset)*cos(i*altimeterAngleStep+HALF_PI),y-(altimeterInsideWidth/2-bigLineLength-altimeterTextOffset)*sin(i*altimeterAngleStep+HALF_PI));
        
        pushMatrix();
        translate(x,y);
        rotate(i*altimeterAngleStep);
      } else {
        strokeWeight(smallLineWidth);
        line(0,0-altimeterInsideWidth/2+smallLineLength,0,0-altimeterInsideWidth/2);
      }
      popMatrix();
    }
    
    textSize(titleTextSize);
    text("ALTIMETER",x,y-titleTextOffset);
  }
  
  void display(float altitude){
    displayFixed();
    
    textSize(altimeterCounterTextSize);
    stroke(255);
    strokeWeight(quadrantLineWidth);
    fill(0);
    rectMode(CENTER);
    
    rect(x,y+quadrantOffset,quadrantWidth,quadrantHeight);
    for(int j=1; j<=5; j++){
      float lineX = x-quadrantWidth/2+j*quadrantWidth/5;
      float lineY1 = y+quadrantOffset/2+quadrantLineWidth*2;
      float lineY2 = y+quadrantOffset/2+quadrantHeight+quadrantLineWidth*2;
      
      line(lineX,lineY1,lineX,lineY2);
      fill(255);
      char[] altitudeArray = nf(int(altitude),5).toCharArray();
      altitudeArray[4] = '0';
      text(altitudeArray[j-1],lineX-quadrantWidth/10,lineY1+quadrantHeight/2-quadrantLineWidth*2);
    }
    
    noStroke();
    pushMatrix();
    translate(x,y);
    
    //Thousands
    float thousands = altitude/1000;
    
    pushMatrix();
    rotate(thousands*5*altimeterAngleStep);
    rectMode(CORNER);
    
    fill(245);
    
    rect(-thousandsNeedleWidth/2,0,thousandsNeedleWidth,-thousandsNeedleLength);
    triangle(-thousandsNeedleWidth/2,-thousandsNeedleLength+needleOffset,thousandsNeedleWidth/2,-thousandsNeedleLength+needleOffset,0,-thousandsNeedleLength-needleTipLength);
    
    popMatrix();
    
    //Hundreds
    float hundreds = altitude-(floor(altitude)/1000)*1000;
    
    pushMatrix();
    rotate(hundreds/100*5*altimeterAngleStep);
    
    rect(-hundredsNeedleWidth/2,0,hundredsNeedleWidth,-hundredsNeedleLength);
    triangle(-hundredsNeedleWidth/2,-hundredsNeedleLength+needleOffset,hundredsNeedleWidth/2,-hundredsNeedleLength+needleOffset,0,-hundredsNeedleLength-needleTipLength);
    
    popMatrix();
    popMatrix();
    
        
    noStroke();
    ellipse(x,y,needleCacheWidth,needleCacheWidth);
  }
}
