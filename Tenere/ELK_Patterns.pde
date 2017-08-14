/*
 ---------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------
 ------------------------------------FINISHED-------------------------------------
 ---------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------
 */

/************
 * Heartbeat pattern, based on BPM. First (growing) beat is fainter, 
 * second (receding) beat is brighter. Offset between two beats scales 
 * as BPM changes.
 ************/
public static class Heartbeat extends LXPattern {
  // by Eric Kent

  final static float centerX = 0*FEET;
  final static float centerY = 8*FEET;
  final static float centerZ = 0*FEET;
  final static float innermost = 3.9*FT;
  final static float outermost = 20.7*FT;
  final static float startRad = 15*FT;
  final static float offsetScale = .5;

  final static int START_BPM = 60;
  final static int MIN_BPM = 40;
  final static int MAX_BPM = 180;
  final static int startRate = 60000/START_BPM;
  final static int minRate = 60000/MIN_BPM;
  final static int maxRate = 60000/MAX_BPM;

  private final CompoundParameter rate = 
    new CompoundParameter("Rate", startRate, minRate, maxRate)
    .setDescription("Controls the pulse rate");

  // Parameter for the edge of the pulse
  private final CompoundParameter radius =
    new CompoundParameter("radius", startRad, innermost, outermost)
    .setDescription("Controls the radius of the pulse");

  private final TriangleLFO firstBeat = new TriangleLFO(innermost, radius, rate);
  private final TriangleLFO secondBeat = new TriangleLFO(innermost, radius, rate);
  //private final TriangleLFO firstBeat = new TriangleLFO(innermost, radius, Sensors.heartRate);
  //private final TriangleLFO secondBeat = new TriangleLFO(innermost, radius, heartRate);

  double beatOffset = rate.getValue()*FT/1000 * offsetScale;
  double offsetD = 0;

  public Heartbeat(LX lx) {
    super(lx);
    addParameter(rate);
    addParameter(radius);
    startModulator(firstBeat);
    startModulator(secondBeat);
    firstBeat.setStartValue(beatOffset);
  }

  // Helper function to know current modulation rate, in BPM
  public double getBPM() {
    return 60000/rate.getValue();
  }

  // Helper function to set modulation rate, given desired BPM
  public void setBPM(double BPM) {
    rate.setValue(60000/BPM);
  }

  public void run(double deltaMs) {

    // if rate has changed since last check, scale beat offset accordingly
    offsetD = (rate.getValue()*FT/1000 * offsetScale) - beatOffset;
    if (offsetD != 0) {
      this.firstBeat.setValue(this.firstBeat.getValue() + offsetD);
      beatOffset = rate.getValue()*FT/1000 * offsetScale;
      offsetD = 0;
    }

    double firstRad = this.firstBeat.getValue();
    double secondRad = this.secondBeat.getValue();

    for (LXPoint p : model.points) {
      // if point is inside first or second pulse, asign it color
      if ((sq((float)p.x - centerX) + sq((float)p.y - centerY) + sq((float)p.z - centerZ)) < sq((float)firstRad)) {
        colors[p.index] = palette.getColor(p, 50);
      } else if ((sq((float)p.x - centerX) + sq((float)p.y - centerY) + sq((float)p.z - centerZ)) < sq((float)secondRad)) {
        colors[p.index] = palette.getColor(p, 100);
      } else { // otherwise asign it black
        colors[p.index] = #000000;
      }
    }
  }
}



/************
 * 3D game of life, built upon 2D rules (by normalizing number of neighors to 8)
 ************/
public static class GameOfLife extends LXPattern {
  // by Eric Kent

  final static float REACH = 8*IN;
  final static int START_RATIO = 10; // inverse of fraction that start out alive
  final static int UNDERPOP = 1;
  final static int OVERPOP = 4;
  final static int BIRTH = 3;
  final int numLeaves;

  double time = 0;
  int wait;
  final static int startBPM = 720;
  final static int minBPM = 300;
  final static int maxBPM = 1500;  // Probably dictated by processing speed???
  final static int startRate = 60000/startBPM;
  final static int minRate = 60000/minBPM;
  final static int maxRate = 60000/maxBPM;

  final static int startRand = 20;
  final static int minRand = 10;
  final static int maxRand = 50;

  private boolean[] isAlive;
  private boolean[] tempLives;
  private ArrayList<ArrayList<Integer>> neighbors = new ArrayList<ArrayList<Integer>>();

  private final CompoundParameter rate = 
    new CompoundParameter("Rate", startRate, minRate, maxRate)
    .setDescription("Controls the pulse rate");

  private final CompoundParameter randomness = 
    new CompoundParameter("Rand", startRand, minRand, maxRand)
    .setDescription("Controls the number of random Births per cycle");

  public GameOfLife(LX lx) {
    super(lx);
    addParameter(rate);
    addParameter(randomness);
    numLeaves = model.points.length;
    wait = round((float)rate.getValue());

    // Initialize lives (and tempLives)
    isAlive = new boolean[numLeaves];
    tempLives = new boolean[numLeaves];
    // assign each START_RATIO'th leaf to start out alive
    for (int i=0; i<numLeaves; i++) {
      isAlive[i] = (i % START_RATIO == 0) ? true : false;
    }

    // Initialize neighbors
    for (int j=0; j<numLeaves; j++) {
      neighbors.add(new ArrayList<Integer>());

      int k = 0;
      for (LXPoint p : model.points) {
        if ((sq((float)p.x - (float)model.points[j].x) +
          sq((float)p.y - (float)model.points[j].y) + 
          sq((float)p.z - (float)model.points[j].z)) < sq(REACH)) {
          // This point is a neighbor of p[j], add it to p[j]'s list of neighbors
          neighbors.get(j).add(new Integer(k));
        }
        k++;
      }
    }
  }

  private boolean computeLife(int i) {
    // Cacluate living neighbors
    int livingN = 0;
    int numN = neighbors.get(i).size();
    for (Integer n : neighbors.get(i)) {
      if (isAlive[n.intValue()]) livingN++;
    }

    // Normalize for 8 neighbors
    float ratio = numN/8;

    // **Rules of life/death**
    if (isAlive[i]) {                               // if [i] is alive
      if (livingN*ratio < UNDERPOP) return false;     //and if <UNDERPOP neighbors alive, kill [i]
      else if (livingN*ratio > OVERPOP) return false; //else if >OVERPOP neighbors alive, kill [i]
      else return true;                               //otherwise [i] stays alive
    } else {                                        // if [i] is dead
      return (livingN*ratio == BIRTH) ? true :false;  //and only if BIRTH neighbors alive, make [i] alive
    }
  }

  private static int randomNo(int range) {
    return (int) Math.floor(Math.random() * range);
  }

  public void run(double deltaMs) {
    // Parameter of rate modifies delay between each step
    time += deltaMs;
    wait = round((float)rate.getValue());
    if (time >= wait) {

      // iterate over lives and set temporary bool array with new values; if alive: on, if dead: off
      for (int i=0; i<isAlive.length; i++) {
        tempLives[i] = computeLife(i);
      }
      isAlive = tempLives;

      // add randomness
      int numRandBirths = round((float)randomness.getValue());
      for (int j=0; j<numRandBirths; j++) {
        int randInt = randomNo(numLeaves);
        isAlive[randInt] = true;
      }

      time = 0;
    }

    int j=0;
    for (LXPoint p : model.points) {
      colors[p.index] = isAlive[j] ? colors[p.index] = palette.getColor(p, 100) : #000000;
      j++;
    }
  }
}



/************
 * Pattern that generates several ripples that modify the color of a rotating background color, 
 * based on BPM. Creates one Ripple for every 2 beats.
 ************/
public static class Splashes extends LXPattern {
  // by Eric Kent
  
  private final static int NUM_SPLASHES = 4;
  private final static float RIPPLE_WIDTH = 2*FT;
  private final static float MIN_BRIGHT = 50.0;
  final static float centerX = 0*FEET;
  final static float centerY = 8*FEET;
  final static float centerZ = 0*FEET;
  final float innermost;
  final float outermost;
  final float maxRipple;
  
  List<LXLayer> ripples;
  
  final static int START_BPM = 60;
  final static int MIN_BPM = 40;
  final static int MAX_BPM = 180;
  final static int startRate = 960000/START_BPM;
  final static int minRate = 960000/MIN_BPM;
  final static int maxRate = 960000/MAX_BPM;
  
  private final CompoundParameter rippleRate = 
    new CompoundParameter("Rate", startRate, minRate, maxRate)
    .setDescription("Controls the rate of the ripple instance");


  public Splashes(LX lx) {
    super(lx);

    // Find actual bounds
    float inner = 10*FT;
    float outer = 15*FT;
    for (LXPoint p : model.points) {
      float rad = sqrt(sq(p.x-centerX)+sq(p.y-centerY)+sq(p.z-centerZ));
      if (rad<inner) inner=rad;
      if (rad>outer) outer=rad;
    }
    innermost = inner-1;
    outermost = outer+1;
    maxRipple = 2*outermost+RIPPLE_WIDTH;

    for (int i=0; i<NUM_SPLASHES; ++i) {
      addLayer(new Ripple(lx, i));
    }
    ripples = getLayers();
    
    addParameter(rippleRate);
  }
  
  // Helper function to know current modulation rate, in BPM
  public double getBPM() {
    return 960000/rippleRate.getValue();
  }

  // Helper function to set modulation rate, given desired BPM
  public void setBPM(double BPM) {
    rippleRate.setValue(960000/BPM);
  }

  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      float tempHue = palette.getHuef(p);
      float tempBri = MIN_BRIGHT;
      
      for (int i=0; i<ripples.size(); i++) {
        float effect = ((Ripple)ripples.get(i)).isAffected(p);
        tempHue += effect;
        tempBri += effect;
      }
      tempHue = tempHue%360;
      tempBri = tempBri%100;
      colors[p.index] = LX.hsb(tempHue,100,tempBri);
    }
  }

  private class Ripple extends LXLayer {
    private final static float MAX_EFFECT = 100.0;
    private float rippleX, rippleY, rippleZ;
    private float peakEffect;
    private final SawLFO ripple = new SawLFO(0, maxRipple, rippleRate);

    //Unused constructor (no index)
    Ripple(LX lx) {
      super(lx);
    }
    //Real constructor (with index)
    Ripple(LX lx, int i) {
      super(lx);
      //startModulator(ripple.setStartValue(maxRipple*i/NUM_SPLASHES));
      startModulator(ripple);
      ripple.onSetValue(maxRipple*i/NUM_SPLASHES);
      init();
    }

    private void init() {
      float newRad = (float) Math.random()*outermost;
      rippleX = (float) Math.random()*2*newRad - newRad;
      rippleZ = (float) Math.random()*2*(sqrt(sq(newRad)-sq(rippleX))) - (sqrt(sq(newRad)-sq(rippleX)));
      rippleY = sqrt(sq(newRad)-sq(rippleX)-sq(rippleZ)) + centerY;
      rippleX += centerX;
      rippleZ += centerZ;
      peakEffect = MAX_EFFECT*(float)Math.random();
    }

    //returns effect value (float) of ripple if p is affected
    private float isAffected(LXPoint p) {
      float phaseRad = ripple.getValuef();
      float rad = sqrt(sq((float)p.x - rippleX) + sq((float)p.y - rippleY) + sq((float)p.z - rippleZ));
      if (rad < phaseRad+RIPPLE_WIDTH/2 && rad > phaseRad-RIPPLE_WIDTH/2) {
        return peakEffect - Math.abs(rad-phaseRad)*(peakEffect/RIPPLE_WIDTH);
      }
      else return 0.0;
    }

    public void run(double deltaMs) {
      if (this.ripple.loop()) {
        init();
      }
    }
  }
}



/*
 ---------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------
 --------------------------------UNDER DEVELOPMENT--------------------------------
 ---------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------
 */

/** 
 * WILL EVENTUALLY BE:
 * Dripping rainbow icing down a torus
 * 
 * CURRENTLY ONLY:
 * An adjustable torus
 */
public static class Donut extends LXPattern {
  //by Eric Kent

  final static float startTubeR = 6.415*FT;
  final static float startTubeT = 3.6*FT;
  final static float startTorusR = 10.4*FT;
  final static float startY = 9.5*FEET;
  final static float innermost = 3.9*FT;
  final static float outermost = 20.7*FT;
  final static float middle = (outermost-innermost) / 2;

  public final CompoundParameter tubeR = 
    new CompoundParameter("TubeR", startTubeR, 0, outermost)
    .setDescription("Controls the radius of torus tube");

  public final CompoundParameter torusR = 
    new CompoundParameter("TorusR", middle, innermost, outermost)
    .setDescription("Controls the radius to the center of the tub");

  public final CompoundParameter tubeT = 
    new CompoundParameter("TubeT", startTubeT, 0, startTubeR)
    .setDescription("Controls the thickness of torus tube");

  public final CompoundParameter centerY = 
    new CompoundParameter("Y", startY, 0, outermost)
    .setDescription("Controls the height of torus");

  public Donut(LX lx) {
    super(lx);
    addParameter(tubeR);
    addParameter(torusR);
    addParameter(tubeT);
    addParameter(centerY);
  }

  public void run (double deltaMs) {
    for (LXPoint p : model.points) {
      //torus cartesian calcuation
      //      if ((sq(p.y) + sq((float)torusR.getValue() - sqrt(sq(p.x)+sq(p.z))) 
      //                   - sq(centerY) - 2*centerY*sqrt(sq((float)tubeR.getValue())-sq((float)torusR.getValue() - sqrt(sq(p.x)+sq(p.z))))) < sq((float)tubeR.getValue())) {
      if ((sq((float)torusR.getValue() - sqrt(sq(p.x)+sq(p.z))) + sq(p.y-(float)centerY.getValue())) < sq((float)tubeR.getValue()) && 
        (sq((float)torusR.getValue() - sqrt(sq(p.x)+sq(p.z))) + sq(p.y-(float)centerY.getValue())) > sq((float)tubeT.getValue())) {
        colors[p.index] = palette.getColor(p, 100);
      } else {
        colors[p.index] = #000000;
      }
    }
  }
}



/** 
 * WILL EVENTUALLY BE:
 * Spherical game of Snake (a la Nokia brick), either playing automatically or controlled by TBD user inputs
 * 
 * CURRENTLY ONLY:
 * A null-pointer exception piece of shit
 */
public static class Snake extends LXPattern {
  //by Eric Kent

  final static int nTiers = 4; // MUST BE >=1
  final static char maxTiers = 7;
  final float innermost;
  final float outermost;
  final static float centerX = 0*FEET;
  final static float centerY = 8*FEET;
  final static float centerZ = 0*FEET;

  final static int startBPM = 120;
  final static int minBPM = 60;
  final static int maxBPM = 720;
  final static int startRate = 60000/startBPM;
  final static int minRate = 60000/minBPM;
  final static int maxRate = 60000/maxBPM;
  double time = 0;
  int wait;
  int currCount = 0;
  int currRow = 0;
  int currTier = 0;

  class Block {
    private int tier; // discrete distance from center
    private int level; // layer along y-axis
    private int place; // location around y-axis
    private int count;
    private ArrayList<LXPoint> contents;

    Block(int absCount) {
      // Determine tier & count by iterating out through tiers
      int tempCount = absCount;
      tier = 0;
      while (true) {
        count = tempCount;
        tempCount -= pow(2, 2*tier+3);
        tier++;
        if (tempCount < 0) break;
      }

      int tempPlace = count;
      level = 0;
      while (true) {
        place = tempPlace;
        tempPlace -= pow(2, tier+1);
        if (tempPlace < 0) break;
        level++;
      }

      contents = new ArrayList<LXPoint>();
    }
  }

  private Block[] blocks;
  private ArrayList<Block> pBlocks;

  public final CompoundParameter rate = 
    new CompoundParameter("Rate", startRate, minRate, maxRate)
    .setDescription("Controls the snake refresh rate");

  public void prune() {
    for (Block b : blocks)
      if (b.contents.size() > 5) pBlocks.add(b);
  }

  public Snake(LX lx) {
    super(lx);
    addParameter(rate);

    // Count the number of total number of blocks across all tiers
    int numBlocks = 0;
    for (int i=0; i<nTiers; i++) numBlocks += pow(2, 2*i+3);
    // Initialize all blocks
    blocks = new Block[numBlocks];
    for (int i=0; i<numBlocks; i++) blocks[i] = new Block(i);

    // iterator for test printlns
    int test = 0;

    // Find actual innermost and outermost
    float inner = 10*FT;
    float outer = 15*FT;
    for (LXPoint p : model.points) {
      float rad = sqrt(sq(p.x-centerX)+sq(p.y-centerY)+sq(p.z-centerZ));
      if (rad<inner) inner=rad;
      if (rad>outer) outer=rad;
    }
    innermost = inner-1;
    outermost = outer+1;

    // Assign each point to a block
    for (LXPoint p : model.points) {
      float rad = sqrt(sq(p.x-centerX)+sq(p.y-centerY)+sq(p.z-centerZ));

      float stepsize = (outermost - innermost)/nTiers;
      int tier = floor((rad-innermost)/stepsize);

      int level = floor(((p.y + (tier+1)*stepsize)-centerY)/stepsize);

      float phi = atan2(p.z-centerZ, p.x-centerX);
      phi += PI/2;
      if (phi > PI) phi -= 2*PI;
      phi += PI;

      int place = (int)floor(phi / (2*PI / (int)pow(2, tier+2)));

      // count within the tier
      int count = level*(int)pow(2, tier+2) + place;
      // increment by how many have been in earlier tiers
      int abscount = count;
      for (int i=0; i<tier; i++) abscount += pow(2, 2*i+3);
      // append point to the corresponding block's contents
      if (abscount >= numBlocks) println("Throwing an error at "+test+" because abscount="+abscount+", tier="+tier+", count="+count+", place="+place+", level="+level+", x="+p.x+",y="+p.y+",z="+p.z);
      blocks[abscount].contents.add(p);

      /*
      if (test%200==0) {
       println(test+" added to "+abscount);
       println(abscount+" has "+blocks[abscount].contents.size()+" LXPoints");
       }*/


      // Test code for checking locations, only shows every Xth to get a good variety displayed
      /*
      int X = 200;
       if (test % X == 0) {
       println("\n"+"***i = "+test);
       println("x = "+p.x);
       println("y = "+(p.y-centerY));
       println("z = "+p.z);
       println("rad = "+rad);
       println("phi = " + phi);
       println("tier = " + tier);
       println("level = " + level);
       println("place = " + place);
       println("count = " + count);
       }*/
      test++;
    }
    prune();
  }

  /*
  private boolean isNeighbor(Block next, Block prev) {
   // IF STAYING ON SAME TIER
   if (next.tier == prev.tier) {
   
   // AND IF ON THE SAME LEVEL
   if (next.level == prev.level) {
   
   // AND IF ON A WRAP POINT
   if ((next.place == 0 || prev.place == 0) &&
   (next.place+prev.place == (int)pow(2,next.tier+1)))
   return true;
   
   // ELSE IF INCREMENTAL
   else if (abs(next.place-prev.place)==1)
   return true;
   }
   
   // ELSE IF ADJACENT IN THE NEXT LEVEL
   else if (abs(next.level-prev.level)==1 && next.place==prev.place)
   return true;
   
   }
   
   // ELSE IF GOING INWARD
   else if (next.tier == prev.tier-1) return true;
   
   // ELSE IF GOING OUTWARD
   else if (next.tier == prev.tier+1) return true;
   
   // if not on same or next tier, not a neighbor
   else return false;
   }*/



  public void run (double deltaMs) {
    // As a test, iterate over each zone in each layer

    // Parameter of rate modifies delay between each step
    time += deltaMs;
    wait = round((float)rate.getValue());
    if (time >= wait) {
      println("currCount = "+currCount);

      for (LXPoint p : pBlocks.get(currCount).contents) {
        colors[p.index] = palette.getColor(p, 100);
      }


      time = 0;
      currCount++;

      if (currCount >= pBlocks.size()) {
        currCount = 0;

        for (LXPoint p : model.points) {
          colors[p.index] = #000000;
        }
      }
    }
  }
}