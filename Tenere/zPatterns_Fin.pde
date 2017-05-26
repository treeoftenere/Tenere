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
    
    public final CompoundParameter rate =
    new CompoundParameter("Rate", 10000, 20000, 1000 )
    .setDescription("Rate");
   
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
    addParameter(rate);
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
      + SinVertical( p.x, p.y, (float) size.getValue()) 
      + SinRotating( p.x, p.y, (float) size.getValue()) 
      + SinCircle(   p.x, p.y,p.z, (float) size.getValue()) /3;
      
      red = map(sin(shade*PI), -1, 1, 0, brightness);
      //green =  map(sin(shade*PI+2), -1, 1, 0, brightness);
      blue = map(sin(shade*PI+4), -1, 1, 0, brightness);


      colors[p.index]  = LX.rgb((int)red,(int)green, (int)blue);
      
      //DEV
      //if(counter > nextCheck)
      //{
      //  print("shade="); print(shade);
      //  print(" movement="); print(movement);
      //  println();
      //  nextCheck += checkEvery;
      //}
      
      counter++;
    }

  //advance through time. Sclaed down as LX does some millions of itternations per second.
   movement = counter/(float)rate.getValue();
   
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