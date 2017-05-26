public static class Plasma extends LXPattern {
  
  //variables
  float red, green, blue;
  float shade;
  float movement = 0;
  int minShade = -100;
  int maxShade = 100;
  

  float circleBoundary = 3;
  
  long counter = 0;
  long nextCheck = 500000;
  long checkEvery = 500000;
    
    public final CompoundParameter brightness =
    new CompoundParameter("bright", 255, 255)
    .setDescription("bright");
    
    public final CompoundParameter size =
    new CompoundParameter("Size", 1, 5)
    .setDescription("Size");
    
    public final CompoundParameter rate =
    new CompoundParameter("Rate", 0.05f, 0.5f)
    .setDescription("Rate");
    
    public final CompoundParameter scale =
    new CompoundParameter("Scale", 2,500)
    .setDescription("Scale");
    
    public final CompoundParameter CSpeedX =
    new CompoundParameter("CSpeedX", 20000, 40000)
    .setDescription("CSpeedX");
  
    
    public final SinLFO CircleMoveX = new SinLFO(
      model.xMax*-1, // This is a lower bound
      model.xMax*2, // This is an upper bound
      CSpeedX     // This is 3 seconds, 3000 milliseconds
    );

  
  public Plasma(LX lx) {
    super(lx);
    addParameter(size);
    addParameter(rate);
    addParameter(scale);
    addParameter(brightness);
    addParameter(CSpeedX);
    startModulator(CircleMoveX);
  }
    
  public void run(double deltaMs) {
   
    float _size = (float)size.getValue()/10;//sclale down due to parameter constraints
    
    
    
    for (LXPoint p : model.points) {
  
      //shade = SinVerticle( p.xn, p.yn, _size);
      //      + SinRotating( p.xn, p.yn, _size)
      //      + SinCircle(   p.x,  p.y,  _size);
      
      shade = SinCircle(p.x,p.y, _size) ;
      
      red = map(sin(shade*PI), -1,1,0, (float)brightness.getValue());
      //green = sin(shade*PI+2);
      //blue = sin(shade*PI+4); 


      colors[p.index]  = LX.rgb((int)red, 0, 0);
      
      if(counter > nextCheck)
      {
        print("shade="); print(shade);
        print(" red="); print(red);
        print(" size="); print(size.getValue());
        println();
        nextCheck += checkEvery;
      }
      counter++;
    }


  }
  
  float SinVerticle(float x, float y,  float size)
  {
    return sin(x / size + movement);
  }
  
  float SinRotating(float x, float y, float size)
  {
    return sin( (x * sin(movement/50 ) + y * cos(movement/44)) /size ) ;
  }
   
  float SinCircle(float x, float y, float size)
  {
    float cx =  (float)CircleMoveX.getValue();//(float)circleX.getValue();
    float cy = 0; //model.yMax * cos(movement);
    return sin( sqrt(sq(cy-y) + sq(cx-x)) / model.xMax /size  );
  }



}