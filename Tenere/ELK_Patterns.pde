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
    // *magic* to determine which leaves start out alive
    for (int i=0; i<numLeaves; i++) {
      if (i % START_RATIO == 0) isAlive[i] = true;
      else isAlive[i] = false;
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
      if (livingN*ratio == BIRTH) return true;        //and if BIRTH neighbors alive, make [i] alive
      else return false;                              //otherwise [i] stays dead
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
      if (isAlive[j]) {
        colors[p.index] = palette.getColor(p, 100);
      } else {
        colors[p.index] = #000000;
      }
      j++;
    }
  }
}