public static class TheFourSeasons extends LXPattern {
  // by Fin McCarthy finchronicity@gmail.com
  
  long counter = 0;
  long nextCheck = 100;
  long checkEvery = 100;
  
  //private final SawLFO phase = new SawLFO(0, TWO_PI, rate);
  
  public final VariableLFO year = new VariableLFO("Year");
    

  public TheFourSeasons(LX lx) {
    super(lx);
    startModulator(year);
   // addParameter(size);
  }
    
  public void run(double deltaMs) {

      
      //DEV Display variables
      if(counter > nextCheck)
      {
       
        print("year="); println(year.getValue());
        print("counter="); println(counter);
        println();
        nextCheck += checkEvery;
      }
      
      counter++;
    
    
    for (LXPoint p : model.points) {
    
      colors[p.index] =  #00ff00;
    }
  }
}