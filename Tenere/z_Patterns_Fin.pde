public static class Plasma extends LXPattern {
  
  //variables
  float red, green, blue;
  float shadeRed, shadeGreen = 0;
  float movement = 0;
  float brightness = 255;
  //float size = 0.2;
  int minShade = -100;
  int maxShade = 100;
  float nextCheck = 1;
  
    public final CompoundParameter size =
    new CompoundParameter("Size", 1, 5)
    .setDescription("Size");
    
        public final CompoundParameter rate =
    new CompoundParameter("Rate", 1, 100)
    .setDescription("Rate");
  
  public Plasma(LX lx) {
    super(lx);
    addParameter(size);
    addParameter(rate);
  }
    
  public void run(double deltaMs) {
   
    float _size = (float)size.getValue()/10;//sclale down due to parameter constraints
    float _rate = (float)rate.getValue()/100;//sclale down due to parameter constraints
    
    
    for (LXPoint p : model.points) {
  
      
      //shadeRed = SinVerticle(p.xn,p.yn,_size);
            //+ SinRotating(p.xn,p.yn,size) 
      shadeGreen = SinCircle(p.xn,p.yn, _size);
      
    red =  map( sin(shadeRed*PI)*100, minShade, maxShade, 0, brightness);
    green = map( sin(shadeGreen*PI+2*PI)*100, minShade, maxShade, 0, brightness);
    //b = map( sin(shade*PI+4*PI*sin(movement/20))*100, minShade, maxShade, 0, brightness);
    
      colors[p.index] =  LX.rgb((int)red, (int)green, (int)blue);
      
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
    float cx = model.xMax * sin(movement);
    float cy = 0; //model.yMax * cos(movement);
    float dist = sqrt(sq(cy-y) + sq(cx-x));
    return sin((dist/size ) + movement );
  }



}