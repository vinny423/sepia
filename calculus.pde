class Calculus{
  
  int num1Min = 100;
  int num1Max = 900;
  int num2Min = 10;
  int num2Max = 100;
  
  int multMin = 50;
  int multMax = 200;
  int multLow[] = {2,3,4};
  
  int divLow[] = {2,3};
  
  int divMin = 50;
  int divMax = 300;
  int result;
  
  Calculus(){
    
  }
  
  String getRandomCalculation(){
    String calculation;
    
    int rand = int(random(100));
    
    
    if(rand<35) calculation = getAddition();
    else if(rand<70) calculation = getSubstraction();
    else if(rand<90) calculation = getMultiplication();
    else calculation = getDivision();
    
    return calculation;
  }
  
  String getAddition(){
    int num1 = int(random(num1Min,num1Max));
    int num2 = int(random(num2Min,num2Max));
    
    result = num1 + num2;
    
    return num1 +" + "+num2;
  }
  
  String getSubstraction(){
    int num1 = int(random(num1Min,num1Max));
    int num2 = int(random(num2Min,num2Max));
    
    result = num1 - num2;
    
    return num1 +" - "+num2;
  }
  
  String getMultiplication(){
    int mult1 = int(random(multMin,multMax));
    int mult2 = multLow[int(random(multLow.length))];
    
    result = mult1 * mult2;
    
    return mult1 +" x "+mult2;
  }
  
  String getDivision(){
    int div2 = divLow[int(random(divLow.length))];
    int div1 = int(random(divMin,divMax))*div2;
    
    result = div1/2;
    
    return div1 +" ÷ "+div2;
  }
  
  int getResult(){
    return result;
  }
}
