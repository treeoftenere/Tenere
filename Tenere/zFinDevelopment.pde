public class TheFourSeasons extends LXPattern {
  // by Fin McCarthy finchronicity@gmail.com
  
   /*
    //SPRING : Sprouting Leaves, flying birds
      1 fade in leaves as they grow
      2 birds flap around.
      3 wind blows accross the tree
      
    //SUMMER
      2 flames around the base? Smoke effect?
    
    //AUTUMN
      1 leaves start to turn brown
      2 fall down to the ground
      3 dark tree. 
    
    //WINTER
      snow piles up on the tree
      Snow melts away. 
      
     */

  SeasonsHelpers.Seasons season = SeasonsHelpers.Seasons.STARTUP;
  int dayOfTheSeason;
  int summerDays = 10;
  int autumnDays = 1800;
  int winterDays = 1000;
  int springDays = 1000;
  int blossumTime = 300;
  int currentDayOfSpring = 0;
  int nextSeasonChange = 1600; //frames    
  int startupPause = 20;
  

  
  ArrayList<PseudoLeaf> pseudoLeaves;
  int pseudoLeafDiameter = 80;
  
  //COLORS OF CENTRAL PARK 
  //Shades Of Green
  
    int[] centralParkGreen = {
                                LX.rgb(32,89,0), 
                                LX.rgb(74,145,43),
                                LX.rgb(102,153,34),
                                LX.rgb(79,125,52),
                                LX.rgb(119,158,52),
                                LX.rgb(54,89,33),
                                LX.rgb(79,130,27),
                                LX.rgb(102,153,34),
                                LX.rgb(97,137,16),
                                LX.rgb(86,132,8),
                                LX.rgb(75,124,0),
                                LX.rgb(104,128,40),
                                LX.rgb(91,143,19)
                                
                              };
  
  //6 colors of pink
  int[] centralParkBlossums = {
                                LX.rgb(167,13,85), 
                                LX.rgb(176,67,125),
                                LX.rgb(171,49,106),
                                LX.rgb(198,69,125),
                                LX.rgb(191,117,134),
                                LX.rgb(215,161,175),
                                LX.rgb(192,99,109)
                                
                              };
                              
  //10 colors of Brown 
  // .length
  int[] centralParkInAutumn = {
                                LX.rgb(247, 193, 35), 
                                LX.rgb( 255, 158,3),
                                LX.rgb( 255, 96,5),
                                LX.rgb(252,4,2),
                                LX.rgb(196,0,2),
                                LX.rgb(172,0,0),
                                LX.rgb(110,1,0),
                                LX.rgb(107,14,0),
                                LX.rgb(96,13,0),
                                LX.rgb(244,126,3),
                                LX.rgb(111,40,0),
                                LX.rgb(176,113,16),
                                //LX.rgb(191,142,47),
                                LX.rgb(153,99,0),
                               // LX.rgb(203,134,5),
                                LX.rgb(213,89,29)
                              };
  

  public TheFourSeasons(LX lx) {
    super(lx);
   InitializePseudoLeaves();
  }
    
  public void run(double deltaMs) {
    AdvanceTime();
    ActionSeason(); 
  }
  
  public void onActive() 
  {
    season = SeasonsHelpers.Seasons.STARTUP;
    dayOfTheSeason =0;
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
    else if(dayOfTheSeason > nextSeasonChange)
    {
      //Time to change seasons.
      switch(season)
      {
        case SUMMER:
          season = SeasonsHelpers.Seasons.AUTUMN;
          nextSeasonChange = autumnDays;
          CaptureColours();
          println("Autum");
          break;
        case AUTUMN:
          season = SeasonsHelpers.Seasons.WINTER;
          nextSeasonChange = winterDays;
          InitializeWinter();
          println("Winter");
          break;
        case WINTER:
          season = SeasonsHelpers.Seasons.SPRING;
          nextSeasonChange = springDays;
          ClearColors(); //move to season changer
          InitializePseudoLeaves();
          println("Spring - Watch out for swooping Magpies");
          break;
        case SPRING:
          season = SeasonsHelpers.Seasons.SUMMER;
          nextSeasonChange = summerDays;
          InitializePseudoLeaves();
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
  
  void InitializeWinter()
  {
    InitializePseudoLeaves();
    
    for(PseudoLeaf l : pseudoLeaves)
    {
      l.wx = l.x;
      l.wy = l.y;
      l.wz = l.z;
      l.y = l.y + model.yMax+100; //up high, ready for snowfall
      l.colour = LX.rgb(150,150,150); //snow colour
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
    //WHAT SHOULD WE DO FOR SUMMER? (plasma wind?)
  }
  
  void Autumn()
  {
    BrownAutumnLeaves();
  }
  
  void Winter()
  { 
    SnowFall();
  }
  
  void Spring()
  {
    //make the leaves grow
    if(dayOfTheSeason < blossumTime)
    {
      GrowLeaves();
      BlossumsFadeIn(); //grow pink blossums
    }
    else if(dayOfTheSeason == blossumTime) 
    {
      InitializePseudoLeaves(); //reset ready for next growth
    }
    else if( dayOfTheSeason < blossumTime+300)
    {
     //wait
    }
    else //green 
    {
      GrowLeaves();
      LeavesFadeIn(0.03); //grow green leaves lighter
    }
  }//spring
  
  
  
  /* ACTION METHODS ACTION METHODS ACTION METHODS ACTION METHODS ACTION METHODS */

   void InitializePseudoLeaves()
   {
       //make a pseudoleaf for each assemblage. 
       pseudoLeaves = new ArrayList<PseudoLeaf>();
       int assemblageIdx = 0;
       int branchIdx = 0;
       
       for(Branch branch : tree.branches)
       {
         //Branch branch = tree.branches.get(0);
         assemblageIdx=0;
         for(LeafAssemblage assemblage : branch.assemblages)
         {
           //get the leaf nearest the centre so we can get the avg coordinate of this assemblage
           Leaf centreLeaf = assemblage.leaves.get(4);
           
           //make a pseudoleaf marking the same coordinate as the assmeblages middle leaf
           this.pseudoLeaves.add( new PseudoLeaf(
           centreLeaf.point.x,
           centreLeaf.point.y,
           centreLeaf.point.z,
           branchIdx,
           assemblageIdx,  //idx of the associated assemblage so we can get to it fast
           centralParkBlossums[(int)random(0,centralParkBlossums.length)],
           centralParkGreen[(int)random(0,centralParkGreen.length)], 
           centralParkInAutumn[(int)random(0,centralParkInAutumn.length)] 
           )
           );
           assemblageIdx++;
         }
         branchIdx++;
       }
     }
     
     void GrowLeaves()
     {
       for(PseudoLeaf pleaf : pseudoLeaves)
        {
          if(pleaf.size < pseudoLeafDiameter ) pleaf.size += random(0,0.2);
        }
     }
     
      //TODO: refactor the following patterns
     void BlossumsFadeIn()
     {
       float distance = 0;

       //itterate over all the leaves, if close, light up green
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
           //get the associated branch an assemblage
           Branch branch = tree.branches.get(pleaf.branchIndex);
           LeafAssemblage ass = branch.assemblages.get(pleaf.assemblageIndex);
           
           for(Leaf l : ass.leaves)
           {
               distance = dist(l.x, l.y,l.z, pleaf.x,pleaf.y,pleaf.z);
              if(distance < pleaf.size) //close enough to bother about
              {
                setColor(l, LXColor.lerp(colors[l.point.index],pleaf.blossumColour,0.01)); 
              }
           }
        }
     }
     
     //TODO: refactor 
     void LeavesFadeIn(float lerp)
     {
       float distance = 0;

       //itterate over all the leaves, if close, light up green
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
           //get the associated branch an assemblage
           Branch branch = tree.branches.get(pleaf.branchIndex);
           LeafAssemblage ass = branch.assemblages.get(pleaf.assemblageIndex);
           
           for(Leaf l : ass.leaves)
           {
               distance = dist(l.x, l.y,l.z, pleaf.x,pleaf.y,pleaf.z);
              if(distance < pleaf.size) //close enough to bother about
              {
                  setColor(l, LXColor.lerp(colors[l.point.index],pleaf.greenColour,lerp));
                 //pleaf.colour  = LXColor.lerp(pleaf.colour,pleaf.greenColour, 0.02); //transform
                //IlluminateNearby(pleaf, pleaf.colour);
              }
           }
        }
     }

     void SnowFall()
     {
       //clear all colors
       ClearColors();

       //itterate over all the leaves, if close illumiate
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
           //ANIMATE FALLING LEAVES
           if(pleaf.status == SeasonsHelpers.LeafStatus.FALLING) //move snowflake
           {
             pleaf.y -= 10; //TODO make this more fluid
             
             if(pleaf.y <= pleaf.wy)//completed fall
             {
               pleaf.status = SeasonsHelpers.LeafStatus.FALLEN; //fall completed, do nothing.
             }
           }
           //rest untill spring melt //<>//
           else if(pleaf.status == SeasonsHelpers.LeafStatus.FALLEN)
           {
             // zzzzzZZZzzZzzZZzZz do nothing
           } //<>//
           
           //NOT YET FALLING
           else  //randomly set leaf to falling, but dump all at 600
           {
             //a few flakes
             if(dayOfTheSeason < 200 )  //<>//
             {
                if( random(1, 1000) < 2 ) pleaf.status = SeasonsHelpers.LeafStatus.FALLING;
             }

             else if(dayOfTheSeason < 500 ) 
             {
                if( random(1, 300) < 2 ) pleaf.status = SeasonsHelpers.LeafStatus.FALLING;
             }
             //all the flakes
             else 
             {
              pleaf.status = SeasonsHelpers.LeafStatus.FALLING;
             }
           }
           
            IlluminateNearby(pleaf, pleaf.colour);
        }
     }
     
     void BrownAutumnLeaves()
     {
        ClearColors();
        
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
          if(pleaf.status == SeasonsHelpers.LeafStatus.GROWING)
          {
              //make green
              pleaf.colour  = LXColor.lerp(pleaf.greenColour,pleaf.colour,0.05); //transform
              IlluminateNearby(pleaf, pleaf.colour);
          }
          
           if(pleaf.status == SeasonsHelpers.LeafStatus.BROWNING) //BROWNING
           {
             //Been Brown a long time, leave will now fall. 
             if(pleaf.brownTime == 400) //change to falling state
             {
               pleaf.status = SeasonsHelpers.LeafStatus.FALLING; //exit browning
             }
             
             //Continue Browning
              pleaf.colour  = LXColor.lerp(pleaf.colour,pleaf.browningColour,0.05); //transform
              IlluminateNearby(pleaf, pleaf.colour);

             pleaf.brownTime++;
           }
           else if(pleaf.status == SeasonsHelpers.LeafStatus.FALLING) //write over static leaves with falling leaf
           {
            pleaf.y -= 10;
             
             if(pleaf.y < -400)//completed fall
             {
               pleaf.status = SeasonsHelpers.LeafStatus.FALLEN; //fall completed, do nothing.
             }
             
             else //make the leaves fall
             {
               //Check if each branch is in the fall path of this pLeaf.
               IlluminateNearby(pleaf, pleaf.browningColour); //<>//
             }
           }
           else if(pleaf.status == SeasonsHelpers.LeafStatus.FALLEN)
           {
             //do nothing, 
           }
           else if(random(150) < 1) //randomly set leaf to browning
           {
             pleaf.status = SeasonsHelpers.LeafStatus.BROWNING;
           }
        }
     }
        
    void ClearColors()
    {
      for (LXPoint p : model.points) { colors[p.index] = #000000;}
    }
    
    void  CaptureColours()
    {
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
             Branch branch = tree.branches.get(pleaf.branchIndex);
             LeafAssemblage ass = branch.assemblages.get(pleaf.assemblageIndex);
             Leaf l = ass.leaves.get(4);
             pleaf.colour = colors[l.point.index];
       }
    }
    
    void IlluminateNearby(PseudoLeaf pleaf, int colour)
    {
       for(Branch branch : tree.branches)
       {
        //if branch is in the fall zone
        if( dist(branch.x, branch.z, pleaf.x ,pleaf.z) < 300)
        {
           for(LeafAssemblage ass : branch.assemblages)
           {
             //check if the assemblage is nearby
                Leaf l = ass.leaves.get(4);
                float distance = dist(l.x, l.y, l.z, pleaf.x, pleaf.y, pleaf.z);
                if(distance < pseudoLeafDiameter*4)
                {
                  //If nearby, calculate actual distances
                  for(Leaf ll : ass.leaves)
                  {
                    float dist = dist(ll.x, ll.y, ll.z, pleaf.x, pleaf.y, pleaf.z);
                    if(dist < pseudoLeafDiameter)
                    {
                       pleaf.colour = LXColor.lerp(pleaf.colour,colour,0.02);
                       setColor(ll, pleaf.colour);
                    }
                  }
                }
             }
          }
       }//illuminate nearby
    }
}



public class PseudoLeaf 
{
  float x, y, z;
  float wx, wy, wz;
  int assemblageIndex;
  int branchIndex;
  int colour = LX.rgb(0,0,0);
  int blossumColour ;
  float size = 0;
  SeasonsHelpers.LeafStatus status = SeasonsHelpers.LeafStatus.GROWING;
  int brownTime = 0;
  int browningColour;
  int greenColour;
  
 
  public PseudoLeaf(float _x, float _y, float _z, int _branchIdx, int _assemblageIdx, int _blossum, int _green, int _browningColour)
  {
    x = _x;
    y = _y; 
    z = _z;
    branchIndex =_branchIdx;
    assemblageIndex = _assemblageIdx;
    blossumColour = _blossum;
    greenColour = _green;
    browningColour = _browningColour;
  }

}


public static class SeasonsHelpers
{
 enum Seasons {SUMMER, AUTUMN, WINTER, SPRING, STARTUP}
 enum LeafStatus {GROWING, BROWNING, FALLING, FALLEN, WINTERWAITING}

   
}