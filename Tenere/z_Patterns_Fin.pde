public static class Plasma extends LXPattern {
  
  //variables
  float red, green, blue;
  float shadeRed, shadeGreen = 0;
  float movement = 0;
  float brightness = 255;
  int minShade = -100;
  int maxShade = 100;
  float nextCheck = 1;
  float circleBoundary = 3;
  
    public final CompoundParameter size =
    new CompoundParameter("Size", 1, 5)
    .setDescription("Size");
    
    public final CompoundParameter rate =
    new CompoundParameter("Rate", 5, 1)
    .setDescription("Rate");
    
    public final CompoundParameter scale =
    new CompoundParameter("Scale", 2,500)
    .setDescription("Scale");
    
    public final CompoundParameter CSpeedX =
    new CompoundParameter("CSpeedX", 1000, 40000)
    .setDescription("CSpeedX");
    
    public final CompoundParameter CSpeedY =
    new CompoundParameter("CSpeedY", model.xMin, model.xMax)
    .setDescription("CSpeedY");
    
    public final SinLFO CircleMoveX = new SinLFO(
      model.xMax*-1, // This is a lower bound
      model.xMax*2, // This is an upper bound
      CSpeedX     // This is 3 seconds, 3000 milliseconds
    );
    
    public final SinLFO CircleMoveY = new SinLFO(
      model.yMax*-1, // This is a lower bound
      model.xMax*2, // This is an upper bound
      13000     // This is 3 seconds, 3000 milliseconds
    );
  
  public Plasma(LX lx) {
    super(lx);
    addParameter(size);
    addParameter(rate);
    addParameter(scale);
    addParameter(CSpeedX);
    addParameter(CSpeedY);
    startModulator(CircleMoveX);
    startModulator(CircleMoveY);
  }
    
  public void run(double deltaMs) {
   
    float _size = (float)size.getValue()/10;//sclale down due to parameter constraints
    float _rate = (float)rate.getValue()/100;//sclale down due to parameter constraints
    
    
    for (LXPoint p : model.points) {
  
      
      //shadeRed = SinVerticle(p.xn,p.yn,_size);
      //+ SinRotating(p.xn,p.yn,size) 
      shadeGreen = SinCircle(p.x,p.y, _size) * (float)scale.getValue();
      
     //red =  map( sin(shadeRed*PI)*100, minShade, maxShade, 0, brightness);
     //green = LX.hsb(shadeGreen, 100, 100);
     //colors[p.index] =  LX.rgb((int)red, (int)green, (int)blue);
      colors[p.index]  = LX.rgb((int)shadeGreen, 0, 0);
      
      //if(movement > nextCheck)
      //{
      //  println(sin(shade*PI)*100);
      //  nextCheck++;
      //}
    
    }
    
    movement += _rate;
    
 
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
    return sin(sqrt(sq(cy-y) + sq(cx-x)));
  }



}