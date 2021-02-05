class Checkbox{
  float x,y;
  float size;
  float lineSize = 2;
  
  color defaultBackgroundColor = color(255);
  color hoverBackgroundColor = color(230);
  
  boolean clicked = false;
  boolean active = false;
  
  Checkbox(float x, float y, float size){
    this.x = x;
    this.y = y;
    this.size = size;
  }
  
  Checkbox(float x, float y){
    this(x,y,40);
  }
  
  Checkbox(){
    this(0,0,40);
  }
  
  void display(){
    fill(defaultBackgroundColor);
    if(!mouseLocked)checkMouse();
    rectMode(CENTER);
    strokeWeight(1);
    stroke(0);
    rect(x,y,size/2,size/2);
    if(active){
      strokeWeight(lineSize);
      line(x-size/4,y-size/4,x+size/4,y+size/4);
      line(x+size/4,y-size/4,x-size/4,y+size/4);
    }
  }
  
  void setPosition(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  void setActive(boolean active){
    this.active = active;
  }
  
  void checkMouse(){
    if(overRect(x,y,size/4,size/4)){
       fill(hoverBackgroundColor);
       if(leftMouseClicked){
         if(!mouseLocked){
           if(active) active = false;
           else active = true;
           mouseLocked = true;
         }
       }
    } else {
      fill(defaultBackgroundColor);
    }
  }
  
  boolean overRect(float x, float y, float lWidth, float lHeight) {
    if (mouseX >= x-lWidth && mouseX <= x+lWidth && mouseY >= y-lHeight && mouseY <= y+lHeight) return true;
    else return false;
  }
}
