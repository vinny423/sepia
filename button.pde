class Button{
  
  boolean clicked;
  
  float x,y;
  
  String text;
  
  int textSize = 25;
  
  float buttonWidth;
  float buttonHeight;
  
  float buttonBorder = 1;
  
  color defaultBackgroundColor, hoverBackgroundColor, clickedBackgroundColor;
  color textColor = color(0);
  
  Button(String text, float x, float y, float buttonWidth, float buttonHeight){
    this.text = text;
    this.x = x;
    this.y = y;
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    
    setColor(color(255));
  }
  
  Button(String text, float x, float y){
    this(text,x,y,530,100);
  }
  
  void setColor(color newColor){
    defaultBackgroundColor = newColor;
    hoverBackgroundColor = color(red(defaultBackgroundColor),green(defaultBackgroundColor)-10,blue(defaultBackgroundColor)-30);
    clickedBackgroundColor = color(red(defaultBackgroundColor),green(defaultBackgroundColor)-10,blue(hoverBackgroundColor)-30);
  }
  
  void setTextColor(int textColor){
    this.textColor = textColor;
  }
  
  void setPosition(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  void display(float x, float y){
    checkMouse();
    rectMode(CENTER);
    stroke(0);
    strokeWeight(buttonBorder);
    textAlign(CENTER,CENTER);
    textSize(textSize);
    rect(x,y,buttonWidth/2,buttonHeight/2);
    fill(textColor);
    text(text,x,y);
  }
  
  void display(){
    display(x,y);
  }
  
  void setText(String text){
    this.text = text;
  }
  
  void setTextSize(int textSize){
    this.textSize = textSize;
  }
  
  void setSize(float buttonWidth, float buttonHeight){
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
  }
  
  void checkMouse(){
    if(overRect(x,y,buttonWidth/4,buttonHeight/4)){
       fill(hoverBackgroundColor);
       if(leftMouseClicked){
         fill(clickedBackgroundColor);
         if(!mouseLocked){
           clicked = true;
           mouseLocked = true;
         } else clicked = false;
       } else clicked = false;
    } else {
      fill(defaultBackgroundColor);
      clicked = false;
    }
  }
  
  boolean overRect(float x, float y, float lWidth, float lHeight) {
    if (mouseX >= x-lWidth && mouseX <= x+lWidth && mouseY >= y-lHeight && mouseY <= y+lHeight) return true;
    else return false;
  }
}
