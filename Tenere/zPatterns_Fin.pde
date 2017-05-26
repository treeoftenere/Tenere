public static class Plasma extends LXPattern {
  
  //by Fin McCarthy
  // finchronicity@gmail.com
  
  //variables
  int brightness = 255;
  float red, green, blue;
  float shade;
  float movement = 0;
  int minShade = -100;
  int maxShade = 100;
  

  float circleBoundary = 3;
  
  long counter = 0;
  long nextCheck = 500000;
  long checkEvery = 500000;
    
    
    public final CompoundParameter size =
    new CompoundParameter("Size", 0.15, 0.05, 0.5)
    .setDescription("Size");
    
        public final CompoundParameter maxRate =
    new CompoundParameter("MaxRate", 6000, 10000, 3500)
    .setDescription("MaxRate");
   
   
    public final CompoundParameter CSpeedX =
    new CompoundParameter("CSpeedX", 2000, 10000, 40000)
    .setDescription("CSpeedX");
    
        public final SinLFO RateLfo = new SinLFO(
      40000, 
      maxRate, 
      60000     
    );
  
    public final SinLFO CircleMoveX = new SinLFO(
      model.xMax*-1, 
      model.xMax*2, 
      CSpeedX     
    );
    
        public final SinLFO CircleMoveY = new SinLFO(
      model.xMax*-1, 
      model.yMax*2, 
      13000 
    );

  
  public Plasma(LX lx) {
    super(lx);
    
    addParameter(size);
    addParameter(maxRate);
    addParameter(CSpeedX);
    
    startModulator(CircleMoveX);
    startModulator(CircleMoveY);
    startModulator(RateLfo);
  }
    
  public void run(double deltaMs) {
   
    
    for (LXPoint p : model.points) {
     
      //GET A UNIQUE SHADE FOR THIS PIXEL
      shade =
      + SinVertical( p.x, p.y, (float) size.getValue()) 
      + SinRotating( p.x, p.y, (float) size.getValue()) 
      + SinCircle(   p.x, p.y,p.z, (float) size.getValue()) /3;
      
      //SELECTIVELY PULL OUT RED, GREEN, and BLUE 
      red = map(sin(shade*PI), -1, 1, 0, brightness);
      //green =  map(sin(shade*PI+2), -1, 1, 0, brightness);
      blue = map(sin(shade*PI+(4*sin(movement/400))), -1, 1, 0, brightness);

      //COMMIT THIS COLOR 
      colors[p.index]  = LX.rgb((int)red,(int)green, (int)blue);
      
      //DEV
      //if(counter > nextCheck)
      //{
      //  print("RateLfo="); print(RateLfo.getValue());
      //  println();
      //  nextCheck += checkEvery;
      //}
      
      //USED FOR MAKING THE ANIMATION MOVE
      counter++;
    }

  //advance through time. Sclaed down as LX does some millions of itternations per second.
   movement = counter/(float)RateLfo.getValue();
   
  }
  
  float SinVertical(float x, float y,  float size)
  {
    return sin(   ( x / model.xMax / size) + (movement / 100 ));
  }
  
  float SinRotating(float x, float y, float size)
  {
    return sin( ( ( y / model.xMax / size) * sin( movement /134 )) + (x / model.yMax / size) * (cos(movement / 200))  ) ;
  }
   
  float SinCircle(float x, float y,float z, float size)
  {
    float cx =  (float)CircleMoveX.getValue();
    float cy = (float)CircleMoveY.getValue();
    return sin( (sqrt(sq(cy-y) + sq(cx-x) )+ movement + (z/model.zMax)) / model.xMax / size );
  }



}