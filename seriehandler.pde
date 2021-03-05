class SerieHandler{
  String serie[];
  int serieSize = 4;
  int currentPointer;

  SerieHandler(){
    serie = new String[serieSize];
    generateNew();
    println(serie);
  }

  void generateNew(){
    for(int i=0; i<serieSize; i++) serie[i] = String.valueOf(int(random(9)));
    currentPointer = 3;
  }

  String getCurrent(){
    return serie[currentPointer];
  }

  void setNext(){
    currentPointer++;
  }

  boolean hasReachedEnd(){
    return currentPointer == (serieSize);
  }

  int getSerie(){
    String temp = "";
    for(String num : serie) temp += num;

    return Integer.parseInt(temp);
  }
}
