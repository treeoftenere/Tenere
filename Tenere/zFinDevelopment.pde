public class TheFourSeasons extends LXPattern {
  // by Fin McCarthy finchronicity@gmail.com
  
  
  
   /*
    //SPRING : Sprouting Leaves, flying birds
      1 fade in leaves as they grow
      2 birds flap around.
      3 wind blows accross the tree
      
    //SUMMER
      2 Flames around the base? Smoke effect?
    
    //AUTUMN
      1 leaves start to turn brown
      2 fall down to the ground, left right motion, leaving no light where they were. 
      3 Naked dark tree. 
    
    //WINTER
      lightning, rain
      snow piles up on the tree
      Snow melts away. 
      
     */
   
    
  
  SeasonsHelpers.Seasons season = SeasonsHelpers.Seasons.STARTUP;
  int dayOfTheSeason;
  int seasonChange = 400; //frames
  int startupPause = 50;
  
  int deltaMs2;
  
  ArrayList<PseudoLeaf> pseudoLeaves;
  int pseudoLeafDiameter = 60;
  
  public final CompoundParameter xPos = new CompoundParameter("X", 0,model.xMin,model.xMax);
  public final CompoundParameter yPos = new CompoundParameter("Y", 0,model.yMin,model.yMax);
  public final CompoundParameter zPos = new CompoundParameter("Z", 0,model.zMin,model.zMax);

  public TheFourSeasons(LX lx) {
    super(lx);
    
    addParameter("xPos", xPos);
    addParameter("yPos", yPos);
    addParameter("zPos", zPos);
    
    InitializeLeaves();

  }
    
  public void run(double deltaMs) {
    
    AdvanceTime();
    ActionSeason();
     
  }
  
  void AdvanceTime()
  {
    if(season == SeasonsHelpers.Seasons.STARTUP)
    {
      dayOfTheSeason++;
      if(dayOfTheSeason > startupPause)
      {
        season = SeasonsHelpers.Seasons.SPRING;
        dayOfTheSeason = 0;
      }
    }
    else if(dayOfTheSeason > seasonChange)
    {
      //Time to change seasons.
      switch(season)
      {
        case SUMMER:
          season = SeasonsHelpers.Seasons.AUTUMN;
          println("Autum");
          break;
        case AUTUMN:
          season = SeasonsHelpers.Seasons.WINTER;
          println("Winter");
          break;
        case WINTER:
          season = SeasonsHelpers.Seasons.SPRING;
          InitializeLeaves();
          println("Spring - Watch out for swooping Magpies");
          break;
        case SPRING:
          season = SeasonsHelpers.Seasons.SUMMER;
          println("Summertime");
          break;
        default :
          season = SeasonsHelpers.Seasons.SPRING;
          println("Spring. Default season triggered.");
          break;
      }
      dayOfTheSeason = 0; //reset the counter
    }
    else
    {
      dayOfTheSeason++;
    }
  }
  
  void ActionSeason()
  {
        switch(season)
      {
        case SUMMER :
          Summer();
          break;
        case AUTUMN :
          Autumn();
          break;
        case WINTER :
          Winter();
          break;
        case SPRING :
          Spring();
          break;
        case STARTUP :
          Startup();
          break;
      }
  }
  
  void Startup()
  {
    //starting blank so the effect of leaves growing works nicely. 
    for (LXPoint p : model.points) {
      colors[p.index] =  #000000;
    }
  }
  
  //SEASON ACTION 
  void Summer()
  {
    for (LXPoint p : model.points) {
      colors[p.index] =  #ff0000;
    }
  }
  
  void Autumn()
  {
    for (LXPoint p : model.points) {
      colors[p.index] =  #aa7700;
    }
  }
  
  void Winter()
  {
    for (LXPoint p : model.points) {
      colors[p.index] =  #aaaaaa;
    }  
  }
  
  void Spring()
  {
    //make the leaves grow
    GrowLeaves();
    RenderLeaves();
    
    //make the wind blow
    
    //change leaves to brown
    
      
      
  }//spring
  
   void InitializeLeaves()
   {
     ClearColors();
     
     //make a pseudoleaf for each assemblage. 
       pseudoLeaves = new ArrayList<PseudoLeaf>(); //<>//
       int idx = 0;
       int size = 0;
        //<>//
       for(LeafAssemblage assemblage : tree.assemblages)
       {
         //get the leaf nearest the centre so we can get the avg coordinate of this assemblage
         Leaf centreLeaf = assemblage.leaves.get(4);
         
         //make a pseudoleaf marking the same coordinate as the assmeblages middle leaf
         this.pseudoLeaves.add( new PseudoLeaf( //<>//
         centreLeaf.point.x,
         centreLeaf.point.y, //<>//
         centreLeaf.point.z,
         idx) //idx of the associated assemblage so we can get to it fast
         
         );
         
         idx++;
       }
       
     }
     
     void GrowLeaves()
     {
       for(PseudoLeaf pleaf : pseudoLeaves)
        {
          if(pleaf.size < pseudoLeafDiameter ) pleaf.size += random(.9);
          
        }
     }
     
     void RenderLeaves()
     {
       
     float distance = 0;

       //itterate over all the leaves, if close, light up green
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
           //get the associated assemblage
           LeafAssemblage ass = tree.assemblages.get(pleaf.assemblageIndex);
           
           for(Leaf l : ass.leaves)
           {
               distance = dist(l.x, l.y,l.z, pleaf.x,pleaf.y,pleaf.z);
              if(distance < pleaf.size) //close enough to bother about
              {
                int bright = (int)((255 - distance) * ( pleaf.size / pseudoLeafDiameter));
                pleaf.colour = LX.rgb(0,bright,0);
                colors[l.point.index] = pleaf.colour;
              }
           }
        }
     }
        
    void ClearColors()
    {
      for (LXPoint p : model.points) { colors[p.index] = #000000;}
    }
    
}



 public static class PseudoLeaf 
{
  float x, y, z;
  int assemblageIndex;
  int colour = LX.rgb(0,0,0);
  float size = 0;
 
  public PseudoLeaf(float _x, float _y, float _z, int _idx)
  {
    x = _x;
    y = _y; 
    z = _z;
    assemblageIndex = _idx;
  }
  

}


public static class SeasonsHelpers
{
 enum Seasons {SUMMER, AUTUMN, WINTER, SPRING, STARTUP}
 

   
}