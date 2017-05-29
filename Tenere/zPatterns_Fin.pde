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
  
  LXVector circle;
  
  
  long nextCheck = 500000;
  long checkEvery = 500000;
    
    
    public final CompoundParameter size =
    new CompoundParameter("Size", 0.8, 0.1, 1)
    .setDescription("Size");
  
    
    public final SinLFO RateLfo = new SinLFO(
      2, 
      20, 
      45000     
    );
  
    public final SinLFO CircleMoveX = new SinLFO(
      model.xMax*-1, 
      model.xMax*2, 
      40000     
    );
    
        public final SinLFO CircleMoveY = new SinLFO(
      model.xMax*-1, 
      model.yMax*2, 
      22000 
    );

  
  public Plasma(LX lx) {
    super(lx);
    
    addParameter(size);
    
    startModulator(CircleMoveX);
    startModulator(CircleMoveY);
    startModulator(RateLfo);
    
    circle = new LXVector(0,0,0);
    
    println("Model Geometory");
    print("Averages ax, ay, az: "); print(model.ax);print(",");print(model.ay);print(",");println(model.az);
    print("Cerntres cx, cy, cz: ");print(model.cx);print(",");print(model.cy);print(",");println(model.cz);
    print("Maximums xMax, yMax zMax: ");print(model.xMax);print(",");print(model.yMax);print(",");println(model.zMax);
    print("Minimums xMin, yMin zMin: ");print(model.xMin);print(",");print(model.yMin);print(",");println(model.zMin);
    
}
    
  public void run(double deltaMs) {
   
    MoveCircle();
    
    for (LXPoint p : model.points) {
     
      //GET A UNIQUE SHADE FOR THIS PIXEL

      //convert to vector so we can use the distance method
      LXVector pointAsVector = new LXVector(p);
      float _size = (float) size.getValue(); 
      
      shade =
      + (SinVertical(  pointAsVector, _size) 
      + SinRotating(  pointAsVector, _size)) 
      + SinCircle(    pointAsVector, circle, _size) ;
      
      //SELECTIVELY PULL OUT RED, GREEN, and BLUE 
      red = map(sin(shade*PI), -1, 1, 0, brightness);
      green =  map(sin(shade*PI+(2*cos(movement*490))), -1, 1, 0, brightness);
      blue = map(sin(shade*PI+(4*sin(movement*300))), -1, 1, 0, brightness);

      //COMMIT THIS COLOR 
      colors[p.index]  = LX.rgb((int)red,(int)green, (int)blue);
      
      //DEV Display variables
      //if(counter > nextCheck)
      //{
      //  float distance =  pointAsVector.dist(circle);
      //  print("movement="); print(movement);
      //  print(" RateLfo="); println(RateLfo.getValue());
        
      //  println();
      //  nextCheck += checkEvery;
      //}
      
      //USED FOR MAKING THE ANIMATION MOVE
     
    }
    
    movement =+ ((float)RateLfo.getValue() / 1000);

   
  }
  
  float SinVertical(LXVector p, float size)
  {
    return sin(   ( p.x / model.xMax / size) + (movement / 100 ));
  }
  
  float SinRotating(LXVector p, float size)
  {
    return sin( ( ( p.y / model.yMax / size) * sin( movement /66 )) + (p.z / model.zMax / size) * (cos(movement / 100))  ) ;
  }
   
  float SinCircle(LXVector p, LXVector circle, float size)
  {
    float distance =  p.dist(circle);
    return sin( (( distance + movement + (p.z/model.zMax) ) / model.xMax / size) * 2 ); 
  }

  void MoveCircle()
  {
    circle.x = (float)CircleMoveX.getValue();
    circle.y = (float)CircleMoveY.getValue();
  }

}