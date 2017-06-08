public static class TheFourSeasons extends LXPattern {
  // by Fin McCarthy finchronicity@gmail.com
  
  //January is summer. No complaining or I convert the tree model to metric! 
  
  Seasons season = Seasons.SPRING;
  int dayOfTheSeason;
  int seasonChange = 100; //frames
  int startupPause = 50;
  
  LXVector[] leaves;
  int leafDiameter = 120;
  
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
    
    //AdvanceTime();
    ActionSeason();
    
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
   
    
  }
  
  void AdvanceTime()
  {
    if(season == Seasons.STARTUP)
    {
      dayOfTheSeason++;
      if(dayOfTheSeason > startupPause)
      {
        season = Seasons.SPRING;
        dayOfTheSeason = 0;
      }
    }
    else if(dayOfTheSeason > seasonChange)
    {
      //Time to change seasons.
      switch(season)
      {
        case SUMMER:
          season = Seasons.AUTUMN;
          println("Autum.");
          break;
        case AUTUMN:
          season = Seasons.WINTER;
          println("Winter.");
          break;
        case WINTER:
          season = Seasons.SPRING;
          println("Spring. Watch out for swooping Magpies.");
          break;
        case SPRING:
          season = Seasons.SUMMER;
          println("Summertime");
          break;
        default :
          season = Seasons.SPRING;
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
     // LXVector l = new LXVector((float)xPos.getValue(),(float)yPos.getValue(),(float)zPos.getValue());
     //println(xPos.getValue());
    float distance = 0;
    
    for (Branch targetBranch : tree.branches) {
             
        colors[p.index] =  #000000; //first, reset the led for this frame
      
    

      //itterate over all the leaves, if close, light up green
      for(LXVector l : leaves)
      {
        distance = dist(pointAsVector) ;
        if(distance < leafDiameter)
        {
          colors[p.index] =  #00ff00;
        }
      }
      
    } //foreach point
    
  }//spring
  
   void InitializeLeaves()
   {
     int xCount = 12; 
     int zCount = 12;
     int yCount = 7;
     
     int xStart = -1100;
     int yStart = 0;
     int zStart = -1100;
     
     
     leaves = new LXVector[xCount*yCount*zCount]; //<>//
     
     //proceduraly make a 3D grid of leaves
     for(int x = 0; x<xCount; x++)
     {
       for(int y = 0; y<yCount; y++)
       {
         for(int z = 0; z<zCount; z++)
         {
           leaves[x + (y*xCount) + (z*xCount * yCount)] = new LXVector(xStart + (200 * x),
           yStart + (200 * y),zStart + (200 * z));
         }
       }
     }
     
    // Maximums xMax, yMax zMax:  1156.9141,  1249.6746,  1115.6749
    // Minimums xMin, yMin zMin: -1104.0668, -17.902443, -1087.3219

     
     //leaves[0] = new LXVector(100,100,100);
     //leaves[1] = new LXVector(500,500,500);
   }
  //HELPERS
  
  enum Seasons {SUMMER, AUTUMN, WINTER, SPRING, STARTUP}
}