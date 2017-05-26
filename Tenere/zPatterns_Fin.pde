public static class Plasma extends LXPattern {
  
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
    
    //public final CompoundParameter rate =
    //new CompoundParameter("Rate", 0.05, 0.01, 0.5)
    //.setDescription("Rate");
    
    //public final CompoundParameter scale =
    //new CompoundParameter("Scale", 2, 1, 500)
    //.setDescription("Scale");
    
    public final CompoundParameter CSpeedX =
    new CompoundParameter("CSpeedX", 20000, 10000, 40000)
    .setDescription("CSpeedX");
  
    
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
    //addParameter(rate);
    //addParameter(scale);
    addParameter(CSpeedX);
    
    startModulator(CircleMoveX);
    startModulator(CircleMoveY);
    
  }
    
  public void run(double deltaMs) {
   
    
    for (LXPoint p : model.points) {
  
      //shade = SinVerticle( p.x, p.y, _size);
      //      + SinRotating( p.x, p.y, _size)
      //      + SinCircle(   p.x,  p.y,  _size);
      
     
      shade =
      //+ SinVertical( p.x, p.y, (float) size.getValue()) 
      + SinCircle(   p.x,  p.y,  (float) size.getValue());
      
      red = map(sin(shade*PI), -1, 1, 0, brightness);
      //green =  map(sin(shade*PI+2), -1, 1, 0, brightness);
      blue = map(sin(shade*PI+4), -1, 1, 0, brightness);


      colors[p.index]  = LX.rgb((int)red,(int)green, (int)blue);
      
      if(counter > nextCheck)
      {
        print("shade="); print(shade);
        print(" movement="); print(movement);
        println();
        nextCheck += checkEvery;
      }
      counter++;
    }

   movement = counter/5000;//the look rate in LX is in the hudreds of thousands. Scale down.
  }
  
  float SinVertical(float x, float y,  float size)
  {
    return sin(   ( x / model.xMax / size) + (movement / 100 ));
  }
  
  float SinRotating(float x, float y, float size)
  {
    return sin( (x * sin( movement /50 ) + y * cos(movement/44)) /size ) ;
  }
   
  float SinCircle(float x, float y, float size)
  {
    float cx =  (float)CircleMoveX.getValue();
    float cy = 0; //model.yMax * cos(movement);
    return sin( (sqrt(sq(cy-y) + sq(cx-x) )+ movement) / model.xMax / size );
  }



}