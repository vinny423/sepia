class DropdownList{
  String[] elements;
  String firstElement;
  Button[] buttons;

  float x,y;

  float listWidth;
  float listHeight;

  boolean folded = true;
  boolean disabled = false;

  DropdownList(float x, float y, float listWidth, float listHeight, String firstElement, String[] elements){
    elements = splice(elements,firstElement,0);
    buttons = new Button[elements.length];
    for(int i=0; i<elements.length;i++) this.buttons[i] = new Button(elements[i],x,y+listHeight/2*i,listWidth,listHeight);
    this.x = x;
    this.y = y;
    this.listWidth = listWidth;
    this.listHeight = listHeight;
  }

  DropdownList(float x, float y, float listWidth, float listHeight, String firstElement){
    this.firstElement = firstElement;
    this.x = x;
    this.y = y;
    this.listWidth = listWidth;
    this.listHeight = listHeight;
  }
  
  void setElements(String[] elements){
    elements = splice(elements,firstElement,0);
    this.elements = elements;
    buttons = new Button[elements.length];
    for(int i=0; i<elements.length;i++) this.buttons[i] = new Button(elements[i],x,y+listHeight/2*i,listWidth,listHeight);
  }

  void setColor(color newColor){
    for(Button button : buttons) button.setColor(newColor);
  }

  void setTextSize(int textSize){
    for(Button button : buttons) button.setTextSize(textSize);
  }

  void setPosition(float x, float y){
    this.x = x;
    this.y = y;
  }

  void display(){
    getClicks();
    if(folded) fold();
    else unfold();
  }

  void setActive(String active){
    this.elements[0] = active;
  }

  void getClicks(){
    for(Button button: buttons){
      if(button.clicked){
        if(button == buttons[0])
          if(folded) folded = false;
          else folded = true;
        else {
          buttons[0].setText(button.text);
          folded = true;
          button.clicked = false;
        }
      }
    }
  }

  void unfold(){
    for(Button button : buttons){
      button.display();
    }
  }

  void fold(){
    buttons[0].display();
  }

  String getSelection(){
    return buttons[0].text;
  }
}
