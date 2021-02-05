class Slider{
  
  SliderButton sButton;
  float x, y, min, max, size;
  float thickness = 2;
  float textOffset = 50;
  float textSize = 20;
  color textColor = color(0);
  
  boolean displayText = true;
  
  Slider(float x, float y, float size){
    this.x = x;
    this.y = y;
    this.size = size;
    sButton = new SliderButton(x-size/2,y,50,50);
  }
  
  void display(){
    checkClicks();
    stroke(0);
    strokeWeight(thickness);
    line(x-size/2,y,x+size/2,y);
    sButton.display();
    if(displayText){
      textSize(textSize);
      fill(textColor);
      text(nfc(getValue()*100,2),x+size/2+textOffset,y);
      //map(button.x,x-size/2,x+size/2,min,max)
    }
  }
  
  float getValue(){
    return map(sButton.x,x-size/2,x+size/2,min,max);
  }
  
  void setValue(float value){
    sButton.setPosition(map(value,min,max,x-size/2,x+size/2),sButton.y);
  }
  
  void checkClicks(){
    if(sButton.clicked && sButton.x<=x+size/2 && sButton.x>=x-size/2){
        sButton.setPosition(mouseX,y);
        if(sButton.x<x-size/2) sButton.setPosition(x-size/2,y);
        if(sButton.x>x+size/2) sButton.setPosition(x+size/2,y);
    }
  }
  
  void setBoundaries(float min, float max){
    this.min = min;
    this.max = max;
  }
}
