/**
 * Heartbeat pattern, based on BPM. First (growing) beat is fainter, 
 * second (receding) beat is brighter. Offset between two beats scales 
 * as BPM changes.
 */
public static class Heartbeat extends LXPattern {
  // by Eric Kent
  
  final static float centerX = 0*FEET;
  final static float centerY = 8*FEET;
  final static float centerZ = 0*FEET;
  final static float innermost = 3.9*FT;
  final static float outermost = 20.7*FT;
  final static float startRad = 15*FT;
  final static float offsetScale = .5;
  
  final static int startBPM = 60;
  final static int minBPM = 40;
  final static int maxBPM = 180;
  final static int startRate = 60000/startBPM;
  final static int minRate = 60000/minBPM;
  final static int maxRate = 60000/maxBPM;
  
  public final CompoundParameter rate = 
    new CompoundParameter("Rate", startRate, minRate, maxRate)
    .setDescription("Controls the pulse rate");
    
  // Parameter for the edge of the pulse
  public final CompoundParameter radius =
    new CompoundParameter("radius", startRad, innermost, outermost)
    .setDescription("Controls the radius of the pulse");
  
  public final TriangleLFO firstBeat = new TriangleLFO(innermost, radius, rate);
  public final TriangleLFO secondBeat = new TriangleLFO(innermost, radius, rate);
  
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



/** 
 * 3D game of life, built upon 2D rules (by normalizing number of neighors to 8)
 */
public static class GameOfLife extends LXPattern {
  // by Eric Kent

  final static float REACH = 8*IN;
  final static int START_RATIO = 10; // inverse of fraction that start out alive
  final static int UNDERPOP = 2;
  final static int OVERPOP = 3;
  final static int BIRTH = 3;
  final int numLeaves;

  double time = 0;
  int wait;
  final static int startBPM = 120;
  final static int minBPM = 60;
  final static int maxBPM = 720;  // Probably dictated by processing speed???
  final static int startRate = 60000/startBPM;
  final static int minRate = 60000/minBPM;
  final static int maxRate = 60000/maxBPM;

  final static int startRand = 5;
  final static int minRand = 1;
  final static int maxRand = 20;

  private boolean[] isAlive;
  private boolean[] tempLives;
  private ArrayList<ArrayList<Integer>> neighbors = new ArrayList<ArrayList<Integer>>();

  public final CompoundParameter rate = 
    new CompoundParameter("Rate", startRate, minRate, maxRate)
    .setDescription("Controls the pulse rate");

  public final CompoundParameter randomness = 
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
      colors[p.index] = isAlive[j] ? colors[p.index] = palette.getColor(p,100) : #000000;
      j++;
    }
  }
}



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
  * Spherical snake (a la Nokia brick). Each layer out doubles the latitude/longitude
  * boundaries between zones. The exterior layer zones are also considered neighbors
  * with their polar opposite, so the snake can portal to the other side.
  * theta = longitude, phi = latitude
  * 
  * CURRENTLY ONLY:
  * Dividing leaves into spherical zones, then iterating through zones
  */
public static class Snake extends LXPattern {
  //by Eric Kent
  
  final static int nTiers = 2;
  final static char maxTiers = 7; /***DO NOT CHANGE; FIXED TO tier/count DATATYPE!!!***/
  final static float innermost = 3.9*FT;
  final static float outermost = 20.7*FT;
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
  int currTier = 1;
  
  private int[] tier;
  private int[] count;
  
  private float[] phi;
  private float[] theta;
  private float[] rad;
  
  public final CompoundParameter rate = 
    new CompoundParameter("Rate", startRate, minRate, maxRate)
    .setDescription("Controls the snake refresh rate");
  

  
  public Snake(LX lx) {
    super(lx);
    addParameter(rate);
    
    int numLeaves = model.points.length;
    
    // Initialize tier[] and count[]
    phi = new float[numLeaves];     /* [-PI -> PI] */
    theta = new float[numLeaves];   /* [0 -> PI] */
    rad = new float[numLeaves];     
    tier = new int[numLeaves];     /* [1 -> nTiers] */
    count = new int[numLeaves];    /* [0 -> 2^(2*tier+1)-1] */
    
    int i=0;
    for (LXPoint p : model.points) {
      rad[i] = sqrt(sq(p.x-centerX)+sq(p.y-centerY)+sq(p.z-centerZ)); 
      
      // Calculate phi, adjusting for atan limits, and rotating so "0" is on the "bottom"
      phi[i] = atan((p.y-centerY)/(p.x-centerX));
      //correct phi to be phi=0 @ x=1/y=0; phi=(PI||-PI) @ x=-1/y=0 (depending on side)
      if (p.x-centerX < 0) {
        if (p.y-centerY < 0) phi[i] = -(PI-phi[i]);
        else phi[i] += PI;
      }
      //rotate phi values CW by PI/2 so that phi=0 @ x=0/y=-1
      phi[i] += PI/2;
      if (phi[i] > PI) phi[i] -= 2*PI;
      
      // Calculate theta, [0->PI], such that theta=0 @ x=0/z=1; theta=PI @ x=0/z=-1
      theta[i] = acos((p.z-centerZ)/rad[i]);
      
      float stepsize = (outermost - innermost)/nTiers;
      tier[i] = floor((rad[i]-innermost)/stepsize)+1;
      
      int nRows = (int)pow(2,tier[i]);
      float phiPerRow = PI / nRows;
      //determine the row [0->max]
      int row = (int)floor(abs(phi[i] / phiPerRow));
      
      int nPerRow = (int)pow(2,tier[i]+1);
      float thetaPerPlace = 2*PI / nPerRow;
      //determine the place in row [0->max]
      int place = (int)(floor(theta[i] / thetaPerPlace));
      if (p.x-centerX < 0) place = (nPerRow-1)-place;
      
      count[i] = row*(int)pow(2,tier[i]+1) + place;
      
/*      if (i%200==0) {
        println("\n"+"***i = "+i);
        println("x = "+p.x);
        println("y = "+(p.y-centerY));
        println("z = "+p.z);
        println("rad = "+rad[i]);
        println("phi = " + phi[i]);
        println("theta = " + theta[i]);
        println("tier = " + tier[i]);
        println("row = " + row);
        println("place = " + place);
        println("count = " + count[i]);
      }*/
      
      i++;
    }
    
  }
  
  
  private static boolean isNeighbor(int comingN, int leavingN, int comingT, int leavingT) {

    int nPerRow = (int)pow(2,comingT+1);
    int nRows = (int)pow(2,comingT);
    //IF STAYING ON SAME TIER
    if (comingT == leavingT) {

      //if at a wrap point
      if ((comingN % nPerRow == 0) && (leavingN % nPerRow == nPerRow-1) ||
          (leavingN % nPerRow == 0) && (comingN % nPerRow == nPerRow-1)) {
        //and if on same row, return true
        if (abs(comingN-leavingN) == nPerRow-1) return true;
        else return false;
      }
      
      //else if incremental, return true
      else if (abs(comingN-leavingN)==1) return true;
        
      //else if adjacent in the next row, return true
      else if ((comingN % nPerRow == leavingN % nPerRow) && 
               (abs(comingN-leavingN) == nPerRow))
        return true;
      
      else return false;
    }

    //IF GOING INWARD
    else if (leavingT == comingT-1) {
      if (comingN == ceil(leavingN/4)) return true; //***NEEDS TO BE CHANGED TO BIT OPERATORS***
      else return false;
    }
    
    //IF GOING OUTWARD
    else if (leavingT == comingT+1) {
      //check if portaling
      if (comingN == nTiers) {
        //return true if polar opposite
        return true;
      }
      
      //otherwise do bit operations like in inward
      //else if (false) {
      //  return true;
      //}
      
      else return false;
    }
    
    //if not on same or next tier, not a neighbor
    else return false;
  }
  
  public void run (double deltaMs) {
    // As a test, iterate over each zone in each layer
    
    // Parameter of rate modifies delay between each step
    time += deltaMs;
    wait = round((float)rate.getValue());
    if (time >= wait) {
      //println("currCount = "+currCount);
      int i = 0;
      for (LXPoint p : model.points) {
        //if spot is in current step#
        if ((tier[i] == currTier) && (count[i] == currCount)) {
          colors[p.index] = palette.getColor(p,100);
        } else colors[p.index] = #000000;
        i++;
      }
      
      time = 0;
      currCount++;

      if (currCount >= pow(2,2*nTiers+1)) {
        currCount = 0;
        currTier = 1;
      }
      else if (currCount >= pow(2,2*currTier+1)) {
        currCount = 0;
        currTier++;
      }
    }
  }
}