public static class Plasma extends LXPattern {
  
  //by Fin McCarthy
  // finchronicity@gmail.com
  
  //variables
  int brightness = 255;
  float red, green, blue;
  float shade;
  float movement = 0.1;
  
  PlasmaGenerator plasmaGenerator;
  
  long framecount = 0;
    
    //adjust the size of the plasma
    public final CompoundParameter size =
    new CompoundParameter("Size", 0.8, 0.1, 1)
    .setDescription("Size");
  
    //variable speed of the plasma. 
    public final SinLFO RateLfo = new SinLFO(
      2, 
      20, 
      45000     
    );
  
    //moves the circle object around in space
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
    
    plasmaGenerator =  new PlasmaGenerator(model.xMax, model.yMax, model.zMax);
    UpdateCirclePosition();
    
    //PrintModelGeometory();
}
    
  public void run(double deltaMs) {
   
    for (LXPoint p : model.points) {
      
      //GET A UNIQUE SHADE FOR THIS PIXEL

      //convert this point to vector so we can use the dist method in the plasma generator
      float _size = size.getValuef(); 
      
      //combine the individual plasma patterns 
      shade = plasmaGenerator.GetThreeTierPlasma(p, _size, movement );
 
      //separate out a red, green and blue shade from the plasma wave 
      red = map(sin(shade*PI), -1, 1, 0, brightness);
      green =  map(sin(shade*PI+(2*cos(movement*490))), -1, 1, 0, brightness); //*cos(movement*490) makes the colors morph over the top of each other 
      blue = map(sin(shade*PI+(4*sin(movement*300))), -1, 1, 0, brightness);

      //ready to populate this color!
      colors[p.index]  = LX.rgb((int)red,(int)green, (int)blue);

    }
    
   movement =+ ((float)RateLfo.getValue() / 1000); //advance the animation through time. 
   
  UpdateCirclePosition();
    
  }
  
  void UpdateCirclePosition()
  {
      plasmaGenerator.UpdateCirclePosition(
      (float)CircleMoveX.getValue(), 
      (float)CircleMoveY.getValue(),
      0
      );
  }


}



          

/* ------------------------------------------------------------------------------------------------------------------------*/

// This is a helper class to generate plasma. 

  public static class PlasmaGenerator {
      
    //NOTE: Geometory is FULL scale for this model. Dont use normalized values. 
      
      float xmax, ymax, zmax;
      LXVector circle; 
      
      float SinVertical(LXVector p, float size, float movement)
      {
        return sin(   ( p.x / xmax / size) + (movement / 100 ));
      }
      
      float SinRotating(LXVector p, float size, float movement)
      {
        return sin( ( ( p.y / ymax / size) * sin( movement /66 )) + (p.z / zmax / size) * (cos(movement / 100))  ) ;
      }
       
      float SinCircle(LXVector p, float size, float movement)
      {
        float distance =  p.dist(circle);
        return sin( (( distance + movement + (p.z/zmax) ) / xmax / size) * 2 ); 
      }
    
      float GetThreeTierPlasma(LXPoint p, float size, float movement)
      {
        LXVector pointAsVector = new LXVector(p);
        return  SinVertical(  pointAsVector, size, movement) +
        SinRotating(  pointAsVector, size, movement) +
        SinCircle( pointAsVector, size, movement);
      }
      
      public PlasmaGenerator(float _xmax, float _ymax, float _zmax)
      {
        xmax = _xmax;
        ymax = _ymax;
        zmax = _zmax;
        circle = new LXVector(0,0,0);
      }
      
    void UpdateCirclePosition(float x, float y, float z)
    {
      circle.x = x;
      circle.y = y;
      circle.z = z;
    }
    
  }//end plasma generator

  