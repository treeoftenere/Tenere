public class TheFourSeasons extends LXPattern {
  // by Fin McCarthy finchronicity@gmail.com
  
  //Capturing the colors of the four seasons, from Central Park New York,
  //extracted from photography by Patrick Deegan. 
  

  SeasonsHelpers.Seasons season = SeasonsHelpers.Seasons.WINTER;
  int dayOfTheSeason;
  int summerDays = 100;
  int autumnDays = 1800;
  int winterDays = 4000;
  int springDays = 1000;
  int blossumTime = 100;
  int currentDayOfSpring = 0;
  int nextSeasonChange = 1600; //frames    
  int startupPause = 20;
  
  ArrayList<PseudoLeaf> pseudoLeaves;
  int pseudoLeafDiameter = 80;
  
  //COLORS OF CENTRAL PARK 
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
  
  int[] centralParkBlossums = {
                                LX.rgb(167,13,85), 
                                LX.rgb(176,67,125),
                                LX.rgb(171,49,106),
                                LX.rgb(198,69,125),
                                LX.rgb(191,117,134),
                                LX.rgb(215,161,175),
                                LX.rgb(192,99,109)
                              };
                              
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
   //InitializePseudoLeaves();
   InitializeWinter();
  }
    
  public void run(double deltaMs) {
    AdvanceTime();
    ActionSeason(); 
  }
  
  public void onActive() 
  {
    season = SeasonsHelpers.Seasons.WINTER;
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
          //CaptureColours();
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
      l.leafColor = LX.rgb(150,150,150); //snow colour
     l.size = pseudoLeafDiameter;
     l.status = SeasonsHelpers.LeafStatus.WINTERWAITING;
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
    LerpIntoSummer();
  }
  
  void Autumn()
  {
    BrownAutumnLeaves();
  }
  
  void Winter()
  { 
    if(dayOfTheSeason < 1200) {SnowFall();}
    else {SpringMelt();}
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
      LeavesFadeIn(); //grow green leaves lighter
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
     
     void BlossumsFadeIn()
     {
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
           pleaf.leafColor = LXColor.lerp(pleaf.leafColor,pleaf.blossumColor,0.01);
           IlluminateNearby(pleaf);
        }
     }
     
     //TODO: refactor 
     void LeavesFadeIn()
     {
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
           pleaf.leafColor = LXColor.lerp(pleaf.leafColor,pleaf.greenColor,0.03);
           IlluminateNearby(pleaf);
        }
     }
     
  void LerpIntoSummer()
  {
      ClearColors();
      for(PseudoLeaf pleaf : pseudoLeaves)
      {
           pleaf.leafColor = LXColor.lerp(pleaf.leafColor,pleaf.greenColor,(float)dayOfTheSeason/100f);
           IlluminateNearby(pleaf);
      }
  }

     void SnowFall()
     {
         //clear all colors
         ClearColors();
       
         //Set flakes to fall
          if(dayOfTheSeason < 1000 ) 
         {
            SetLowestToSnowing();
         }
         //all the flakes
         else if(dayOfTheSeason == 1000 ) //set all to falling
         {
           for(PseudoLeaf pleaf : pseudoLeaves)
           {
             if(pleaf.status == SeasonsHelpers.LeafStatus.WINTERWAITING)
             {
               pleaf.status = SeasonsHelpers.LeafStatus.FALLING;
             }
           }
         }
         
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
           //rest untill spring melt
           else if(pleaf.status == SeasonsHelpers.LeafStatus.FALLEN)
           {
             // zzzzzZZZzzZzzZZzZz do nothing
           }
           
            IlluminateNearby(pleaf);
        }
     }
     
     void SpringMelt()
     {
      ClearColors(); //<>//
      //set lowest 3 to melting. 
      SetLowestToMelting();
      SetLowestToMelting();
      SetLowestToMelting();
      
       //animate the snow flakes
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
          if(pleaf.status == SeasonsHelpers.LeafStatus.MELTING) //melt to blue
           {
             pleaf.leafColor = LXColor.lerp(pleaf.leafColor, LXColor.rgb(40,40,128), 0.2);
             pleaf.meltTime++; 
             if(pleaf.meltTime > 20){
             pleaf.status = SeasonsHelpers.LeafStatus.FALLING; //<>//
           }
             
         }
           
           //ANIMATE FALLING droplets
           else if(pleaf.status == SeasonsHelpers.LeafStatus.FALLING) //move snowflake
           {
             pleaf.velocity +=  0.1 + (pleaf.velocity*1.02); //TODO make this more fluid
             pleaf.y = pleaf.y - pleaf.velocity;
             
             if(pleaf.y <= pleaf.wy - 4000)//completed fall
             {
               pleaf.status = SeasonsHelpers.LeafStatus.MELTED; //fall completed, do nothing.
             }
           }
           //rest untill spring melt
           else if(pleaf.status == SeasonsHelpers.LeafStatus.MELTED)
           {
             // zzzzzZZZzzZzzZZzZz do nothing
           }
           
            IlluminateNearby(pleaf);
        }
     }
   
     
     void SetLowestToSnowing()
     {
       float lowestvalue = 5000f;
       int lowestindex = -1;
       int counter = 0;;
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
         if(pleaf.status == SeasonsHelpers.LeafStatus.WINTERWAITING && pleaf.y < lowestvalue )
         {
           lowestindex = counter;
           lowestvalue = pleaf.y;
         }
         counter++;
       }
       
       if(lowestindex > -1)
       {
         counter= 0;
        for(PseudoLeaf pleaf : pseudoLeaves)
         {
           if(lowestindex == counter)
           {
             pleaf.status = SeasonsHelpers.LeafStatus.FALLING; //<>//
             break;
           }
           counter++;
         }
       }
     }
     
     void SetLowestToMelting()
     {
       float lowestvalue = 5000f;
       int lowestindex = -1;
       int counter = 0;;
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
         if(pleaf.status == SeasonsHelpers.LeafStatus.FALLEN && pleaf.y < lowestvalue )
         {
           lowestindex = counter;
           lowestvalue = pleaf.y;
         }
         counter++;
       }
       
       if(lowestindex > -1)
       {
         counter= 0;
        for(PseudoLeaf pleaf : pseudoLeaves)
         {
           if(lowestindex == counter)
           {
             pleaf.status = SeasonsHelpers.LeafStatus.MELTING;
             break;
           }
           counter++;
         }
       }
     }
     
     void BrownAutumnLeaves()
     {
        ClearColors();
        
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
          //deal with green leaves first. 
          if(pleaf.status == SeasonsHelpers.LeafStatus.GROWING)
          {
              IlluminateNearby(pleaf);//make current colour, which will be green.
          }
          
         //now deal with brown leaves, overwiring green ones.
         if(pleaf.status == SeasonsHelpers.LeafStatus.BROWNING) //BROWNING
         {
           //Been Brown a long time, leave will now fall. 
           if(pleaf.brownTime == 400) //change to falling state
           {
             pleaf.status = SeasonsHelpers.LeafStatus.FALLING; //exit browning
           }
           
           //Continue Browning
            pleaf.leafColor  = LXColor.lerp(pleaf.leafColor,pleaf.browningColor,0.05); //transform
            IlluminateNearby(pleaf);

             pleaf.brownTime++;
           }
           else if(pleaf.status == SeasonsHelpers.LeafStatus.FALLING) //write over static leaves with falling leaf
           {
            pleaf.y -= 10;
             
             if(pleaf.y < -400)//completed fall
             {
               pleaf.status = SeasonsHelpers.LeafStatus.FALLEN; //fall completed, do nothing.
             }
             
             else //draw this leaf
             {
               IlluminateNearby(pleaf);
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
             pleaf.leafColor = colors[l.point.index];
       }
    }
    
    void IlluminateNearby(PseudoLeaf pleaf)
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
                    if(dist < pleaf.size)
                    {
                       //pleaf.leafColor = LXColor.lerp(pleaf.leafColor,colour,0.02);
                       setColor(ll, pleaf.leafColor);
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
  int leafColor = LX.rgb(0,0,0);
  int blossumColor ;
  float size = 0;
  SeasonsHelpers.LeafStatus status = SeasonsHelpers.LeafStatus.GROWING;
  int brownTime = 0;
  int browningColor;
  int greenColor;
  float velocity = 0;
  int meltTime = 0;
  
 
  public PseudoLeaf(float _x, float _y, float _z, int _branchIdx, int _assemblageIdx, int _blossum, int _green, int _browningColour)
  {
    x = _x;
    y = _y; 
    z = _z;
    branchIndex =_branchIdx;
    assemblageIndex = _assemblageIdx;
    blossumColor = _blossum;
    greenColor = _green;
    browningColor = _browningColour;
    meltTime = 0;
  }

}


public static class SeasonsHelpers
{
 enum Seasons {SUMMER, AUTUMN, WINTER, SPRING, STARTUP}
 enum LeafStatus {GROWING, BROWNING, FALLING, FALLEN, WINTERWAITING, MELTING,MELTED}

   
}