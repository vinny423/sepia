class Compass{
  float x, y;
  
  float compassWidth = 350;
  float compassInsideScale = 0.95;
  float compassInsideWidth = compassWidth*compassInsideScale;
  
  float smallLineLength = 12;
  float smallLineWidth = 2;
  
  float bigLineLength = 22;
  float bigLineWidth = 3;
  
  float compassTextOffset = 20;
  float compassTextSize = compassWidth/12.5;
  
  float bearingIndicatorWidth = 3;
  float bearingIndicatorLength = 50;
  float compassIndicatorOffset = 10;
  
  Compass(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  void displayFixed(){
    fill(0);
    ellipse (x,y,compassWidth,compassWidth);
  }
  
  void display(float rotation){
    displayFixed();
    
    noStroke();
    pushMatrix();
    translate(x,y);
    rotate(radians(rotation%360));
    strokeWeight(2);
    stroke(255);
    fill(25);
    ellipse (0,0,compassInsideWidth,compassInsideWidth);
    
    stroke(255);
    textAlign(CENTER,CENTER);
    textSize(compassTextSize);
    
    for(int i=0; i<36*2; i++){
      pushMatrix();
      rotate(radians(i*5));
      if(i%2 == 1){
        strokeCap(SQUARE);
        strokeWeight(smallLineWidth);
        line(0,0-compassInsideWidth/2+smallLineLength,0,0-compassInsideWidth/2);
      } else {
        strokeWeight(bigLineWidth);
        line(0,0-compassInsideWidth/2+bigLineLength,0,0-compassInsideWidth/2);
        if(i%9 == 0){
          String letter;
          
          switch(i/2){
            case 0: letter = "N"; break;
            case 9: letter = "E"; break;
            case 18: letter = "S"; break;
            case 27: letter = "W"; break;
            default: letter = ""; break;
          }
          fill(255);
          text(letter,0,0-compassInsideWidth/2+bigLineLength+compassTextOffset);
        } else if(i%6 == 0){
          fill(255);
          text(i/2,0,0-compassInsideWidth/2+bigLineLength+compassTextOffset);
        }
      }

      popMatrix();
    }
    
    popMatrix();
    noStroke();
    stroke(#F07F00);
    strokeWeight(bearingIndicatorWidth);
    line(x,y-compassInsideWidth/2+bearingIndicatorLength,x,y-compassInsideWidth/2+compassIndicatorOffset);
    noStroke();
  }
}
