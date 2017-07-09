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
  int summerDays = 10;
  int autumnDays = 2200;
  int winterDays = 300;
  int springDays = 900;
  int currentDayOfSpring = 0;
  int nextSeasonChange = 1600; //frames
  int startupPause = 50;
  
  
  int deltaMs2;
  
  ArrayList<PseudoLeaf> pseudoLeaves;
  int pseudoLeafDiameter = 80;
  

  public TheFourSeasons(LX lx) {
    super(lx);
   
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
    else if(dayOfTheSeason > nextSeasonChange)
    {
      
      //Time to change seasons.
      switch(season)
      {
        case SUMMER:
          season = SeasonsHelpers.Seasons.AUTUMN;
          nextSeasonChange = autumnDays;
          println("Autum");
          break;
        case AUTUMN:
          season = SeasonsHelpers.Seasons.WINTER;
          nextSeasonChange = winterDays;
          println("Winter");
          break;
        case WINTER:
          season = SeasonsHelpers.Seasons.SPRING;
          nextSeasonChange = springDays;
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
    
    
   // if (dayOfTheSeason < 500) //fade is some
    //{
   //   GrowLeaves();
   //   FadeInLeaves(LX.rgb(0,255,0));
    //}
   
  }
  
  void Autumn()
  {
    if (dayOfTheSeason == 0)
    {
      InitializePseudoLeaves();
    }
    BrownAutumnLeaves();
  }
  
  void Winter()
  {
    for (LXPoint p : model.points) {
      colors[p.index] =  #aaaaaa;
    }  
  }
  
  void Spring()
  {
    if(dayOfTheSeason == 0)
    {
      ClearColors();
      InitializePseudoLeaves();
    }
    
    //make the leaves grow
    else if(dayOfTheSeason < 400)
    {
      GrowLeaves();
      FadeInLeaves(LX.rgb(255,70,170)); //grow pink blossums
    }
    else if(dayOfTheSeason == 400) 
    {
      InitializePseudoLeaves(); //reset ready for next growth
    }
    else if(dayOfTheSeason > 400)
    {
      GrowLeaves();
      FadeInLeaves(LX.rgb(20,200, 20)); //grow green leaves
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
         assemblageIdx) //idx of the associated assemblage so we can get to it fast
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
          if(pleaf.size < pseudoLeafDiameter ) pleaf.size += random(.2);
        }
     }
     
     void FadeInLeaves(int c)
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
                pleaf.colour = c;
                colors[l.point.index] = LXColor.lerp(colors[l.point.index],pleaf.colour,0.02);
              }
           }
        }
     }

     
     void BrownAutumnLeaves()
     {
       //cache colors
       if(dayOfTheSeason == 0) //get the green colors
       {
         CaptureColours();
       }
       
       //clear all colors
       ClearColors();

       //raindomly turn some to 'browning'
       
       //itterate over all the leaves, if close, light up green
       for(PseudoLeaf pleaf : pseudoLeaves)
       {
        if(pleaf.status == SeasonsHelpers.LeafStatus.GROWING)
        {
          //make green
             Branch branch = tree.branches.get(pleaf.branchIndex);
             LeafAssemblage ass = branch.assemblages.get(pleaf.assemblageIndex);
             for(Leaf l : ass.leaves)
             {
                colors[l.point.index] = pleaf.colour;
             }
          
        }
           if(pleaf.status == SeasonsHelpers.LeafStatus.BROWNING) //BROWNING
           {
             if(pleaf.brownTime == 1000) //change to falling state
             {
               pleaf.status = SeasonsHelpers.LeafStatus.FALLING; //exit browning
               //println("PLeaf " + pleaf.branchIndex + "-" + pleaf.assemblageIndex + " Falling");
               
               //capture the current colour
               Branch branch = tree.branches.get(pleaf.branchIndex);
               LeafAssemblage ass = branch.assemblages.get(pleaf.assemblageIndex);
               Leaf l = ass.leaves.get(4); //middle leaf
               pleaf.colour = LXColor.lerp(colors[l.point.index],pleaf.browningColor,0.05);
             }
             
             //1ST: Continue Browning
             //get the associated assemblage
              Branch branch = tree.branches.get(pleaf.branchIndex);
              LeafAssemblage ass = branch.assemblages.get(pleaf.assemblageIndex);
              
              pleaf.colour  = LXColor.lerp(pleaf.colour,pleaf.browningColor,0.05); //transform
             
             for(Leaf l : ass.leaves)
             {
                colors[l.point.index] = pleaf.colour;
             }
             
             pleaf.brownTime++;
           }
           else if(pleaf.status == SeasonsHelpers.LeafStatus.FALLING) //write over static leaves with falling leaf
           {
            pleaf.y -= 10; //<>//
             
             if(pleaf.y < -400)//completed fall
             {
               pleaf.status = SeasonsHelpers.LeafStatus.FALLEN; //fall completed, do nothing. //<>//
             }
             
             else //make the leaves fall
             {
               //Check if each branch is in the fall path of this pLeaf.
                
                //foreach branch //<>//
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
                        colors[ll.point.index] = pleaf.browningColor;
                    }
  
                    else
                    {//blacken
                     //   colors[ll.point.index] = 0; //<>//
                    }
                  }
                }
             }
                  }
                 }
             }
           }
           else if(pleaf.status == SeasonsHelpers.LeafStatus.FALLEN)
           {
             pleaf.status =pleaf.status; //catch debugger
           }
           else if(random(200) < 1) //randomly set leaf to browning
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
    
}



 public class PseudoLeaf 
{
  float x, y, z;
  int assemblageIndex;
  int branchIndex;
  int colour = LX.rgb(0,0,0);
  float size = 0;
  SeasonsHelpers.LeafStatus status = SeasonsHelpers.LeafStatus.GROWING;
  int brownTime = 0;
  int browningColor = LX.rgb(150,(int)random(40,130),0);
  
 
  public PseudoLeaf(float _x, float _y, float _z, int _branchIdx, int _assemblageIdx)
  {
    x = _x;
    y = _y; 
    z = _z;
    branchIndex =_branchIdx;
    assemblageIndex = _assemblageIdx;
  }

}


public static class SeasonsHelpers
{
 enum Seasons {SUMMER, AUTUMN, WINTER, SPRING, STARTUP}
 enum LeafStatus {GROWING, BROWNING, FALLING, FALLEN}

   
}