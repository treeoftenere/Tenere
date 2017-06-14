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
      
      //DEV Display variables helper
      //if(framecount % 30 == 0)
      //{
      //  float distance =  pointAsVector.dist(circle);
      //  print("movement="); print(movement);
      //  print(" RateLfo="); println(RateLfo.getValue());
        
      //  println();
      //}
     
     
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

  void PrintModelGeometory()
  {
      println("Model Geometory");
      print("Averages ax, ay, az: ");      print(model.ax);   print(","); print(model.ay);   print(","); println(model.az);
      print("Cerntres cx, cy, cz: ");      print(model.cx);   print(","); print(model.cy);   print(","); println(model.cz);
      print("Maximums xMax, yMax zMax: "); print(model.xMax); print(","); print(model.yMax); print(","); println(model.zMax);
      print("Minimums xMin, yMin zMin: "); print(model.xMin); print(","); print(model.yMin); print(","); println(model.zMin);
  }

}



public class ItemLocationsTest extends LXPattern {
  
  
   int i = 0;
   
     public final CompoundParameter branch =
    new CompoundParameter("branch", 0, 0, 60)
    .setDescription("branch number");
   
    public final CompoundParameter ass =
    new CompoundParameter("ass", 0, 0, 7)
    .setDescription("assemblage number");
   
    public final CompoundParameter leaf =
    new CompoundParameter("leaf", 0, 0, 14)
    .setDescription("leaf number");
   
   
  public ItemLocationsTest(LX lx) {
    
   super(lx);
    
   addParameter("branch", branch);
   addParameter("ass", ass);
   addParameter("leaf", leaf);
   
  }
  
  public void run(double deltaMs) {
    
    for (Branch b : tree.branches) {
    }
    
    //clear colors
   for (LXPoint p : model.points) {
     colors[p.index] = #000000;
   }
   
   
   int branchNumber = (int)branch.getValue();
   int assNumber = (int)ass.getValue();
   int leafNumber = (int)leaf.getValue();

    //show a given branch as red
    Branch targetBranch = tree.branches.get(branchNumber);
    for (LeafAssemblage targetAss : targetBranch.assemblages) {
    for (Leaf targetLeaf : targetAss.leaves) {
      colors[targetLeaf.point.index] = #ff0000;
    }
    
    //show a given assemblage as green
    LeafAssemblage assx = targetBranch.assemblages.get(assNumber);
    for (Leaf targetLeaf : assx.leaves) {
      colors[targetLeaf.point.index] = #00ff00;
    }
    
    //show a given leaf as blue
    Leaf lx = assx.leaves.get(leafNumber);
    colors[lx.point.index] = #0000ff;
    }
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

  
  
  
  
  
  // REFERENCE
  
/*
LIMBS = NUM_LIMBS = 12;
BRANCHES = 
ASSEMBLAGES = 
LEAVES = 

Each Limb has ? Branches
Each branch has 8 LeafAssemblages [branch.assemblage]
Each LeafAssemblage has 15 Leaves
Each Leaf has 7 NUM_LEDS (not yet implemented in code June 5th)

Model Geometory
Averages ax, ay, az: -34.620586,678.9678,73.70307
Cerntres cx, cy, cz: -18.998901,601.6301,17.694458
Maximums xMax, yMax zMax: 1127.384,1275.5334,1166.446
Minimums xMin, yMin zMin: -1165.382,-72.27326,-1131.0573



*/