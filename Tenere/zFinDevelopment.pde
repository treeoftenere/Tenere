public static class TheFourSeasons extends LXPattern {
  // by Fin McCarthy finchronicity@gmail.com
  
  long counter = 0;
  long nextCheck = 30;
  long checkEvery = 30;
  
  enum season {SUMMER, AUTUMN, WINTER, SPRING}
  
  
  //private final SawLFO phase = new SawLFO(0, TWO_PI, rate);
  //public final VariableLFO year = new VariableLFO("Year");
  

  public TheFourSeasons(LX lx) {
    super(lx);
  
   // addParameter(size);
  }
    
  public void run(double deltaMs) {

      /*
     
    //SPRING : Sprouting Leaves, flying birds
      
      1 fade in leaves as they grow
      2 birds flap around.
      3 wind blows accross the tree
      
    
    //SUMMER
      1 hmmmm
      2 Flames around the base? Smoke effect?
    
    //AUTUMN
    
      1 leaves start to turn brown
      2 fall down to the ground, left right motion, leaving no light where they were. 
      3 Naked dark tree. 
    
    
    //WINTER
    
    lightning, rain
    snow piles up on the tree
    Snow melts away. 
      
     */
    
    for (LXPoint p : model.points) {
    
      colors[p.index] =  #00ff00;
    }
    
     counter++;
  }
}