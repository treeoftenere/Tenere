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
    new CompoundParameter("Size", 0.4, 0.05, 0.5)
    .setDescription("Size");
   
    // This is used to make a subtle change to the uniqueness of the plasma, by 
    // movement of the cirlce on the x axis accross the tree. 
    //It is apparent only when the plasma is slow, and helps iliminate repeating patterns. 
    public final CompoundParameter CSpeedX =
    new CompoundParameter("CSpeedX", 2000, 10000, 40000)
    .setDescription("CSpeedX");
    
    public final SinLFO RateLfo = new SinLFO(
      2, 
      20, 
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
    addParameter(CSpeedX);
    
    startModulator(CircleMoveX);
    startModulator(CircleMoveY);
    startModulator(RateLfo);
    
    print("Model Geometory");
    print("Averages ax, ay, az: "); print(model.ax);print(",");println(model.ay);print(",");println(model.az);
    print("Cerntres cx, cy, cz: ");print(model.cx);print(",");println(model.cy);print(",");println(model.cz);
    print("Maximums xMax, yMax zMax: ");print(model.xMax);print(",");println(model.yMax);print(",");println(model.zMax);
    print("Minimums xMin, yMin zMin: ");print(model.xMin);print(",");println(model.yMin);print(",");println(model.zMin);
    
}
    
  public void run(double deltaMs) {
   
    
    for (LXPoint p : model.points) {
     
      //GET A UNIQUE SHADE FOR THIS PIXEL
      float _size = (float) size.getValue();
      
      shade =
      + SinVertical( p.x, _size) 
      + SinRotating( p.x, p.y, p.z, _size) 
      + SinCircle(   p.x, p.y, p.z, _size) /3;
      
      //SELECTIVELY PULL OUT RED, GREEN, and BLUE 
      red = map(sin(shade*PI), -1, 1, 0, brightness);
      green =  map(sin(shade*PI+(2*cos(movement/330))), -1, 1, 0, brightness);
      blue = map(sin(shade*PI+(4*sin(movement/400))), -1, 1, 0, brightness);

      //COMMIT THIS COLOR 
      colors[p.index]  = LX.rgb((int)red,(int)green, (int)blue);
      
      //DEV Display variables
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
   movement += (counter * (float)RateLfo.getValue()) * 0.00000001; //surely there is a beter way to count frames!
   
  }
  
  float SinVertical(float x, float size)
  {
    return sin(   ( x / model.xMax / size) + (movement / 100 ));
  }
  
  float SinRotating(float x, float y, float z, float size)
  {
    return sin( ( ( y / model.yMax / size) * sin( movement /134 )) + (z / model.zMax / size) * (cos(movement / 200))  ) ;
  }
   
  float SinCircle(float x, float y,float z, float size)
  {
    float cx =  (float)CircleMoveX.getValue();
    float cy = (float)CircleMoveY.getValue();
    return sin( (sqrt(sq(cy-y) + sq(cx-x) )+ movement + (z/model.zMax)) / model.xMax / size );
  }



}