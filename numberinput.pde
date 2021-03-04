class NumberInput{

  float x, y;
  float inputWidth, inputHeight;
  color backgroundColor, strokeColor, textColor;
  int maxSize = 5;

  int input = -1;
  int textSize = 40;
  int strokeWeight = 2;
  ArrayList<String> currentInput = new ArrayList<String>();

  NumberInput(float x, float y, float inputWidth, float inputHeight){
    this.x = x;
    this.y = y;
    this.inputWidth = inputWidth;
    this.inputHeight = inputHeight;
    backgroundColor = color(255);
    textColor = strokeColor = color(0);
    strokeColor = color(0);
  }

  void display(){
    rectMode(CENTER);
    fill(backgroundColor);
    stroke(strokeColor);
    strokeWeight(strokeWeight);
    rect(x,y,inputWidth/2,inputHeight/2);
    textSize(textSize);
    textAlign(CENTER, CENTER);
    fill(textColor);
    for(int i=0; i<currentInput.size(); i++){
      text(currentInput.get(currentInput.size()-i-1),x+inputWidth/4-textSize*(i+1),y-3);
    }
  }

  void clearInput(){
    currentInput.clear();
  }

  void validateInput(){
    String temp = "";
    for(String num: currentInput){
      temp+=num;
    }
    input =  Integer.parseInt(temp);

    println("The input is "+input);

    clearInput();
  }

  int getInput(){
    return input;
  }

  void resetInput(){
    input = -1;
  }

  void addNumber(String number){
    if(currentInput.size()<maxSize) currentInput.add(number);
  }

  void handleInput(){
    switch(keyCode){
      case 8: clearInput();
        break;

      case 10: if(currentInput.size()>=1) validateInput();
        break;

      default: addNumber(String.valueOf(key));
        break;
    }
  }
}
