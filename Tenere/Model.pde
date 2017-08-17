import heronarts.lx.model.*;
import java.util.Collections;
import java.util.List;

Tree buildTree() {
  return new Tree(modelMode);
}

public static class StellarBranchConfig {
  final String ip;
  final LXMatrix[] channels = new LXMatrix[Branch.NUM_ASSEMBLAGES]; 
  
  public StellarBranchConfig(String ip) {
    this.ip = ip;
    for (int i = 0; i < channels.length; ++i) {
      channels[i] = null;
    }
  }
}

public static class StellarFixtureConfig {
  
  static final String CHANNEL_ZERO = "Leafs Chanel Zero";
  static final String CHANNEL_FOUR = "Leafs Chanel Four";
  static final int NO_FIXTURE_ID = -1;
  
  // TODO(mcslee): determine accurately what this is!
  static final float ASSEMBLAGE_Y_OFFSET = 4*INCHES;
  
  final String ip;
  final LXMatrix matrix;
  final int fixtureId;
  final int nextFixtureId;
  final int channel;
  
  public StellarFixtureConfig(JSONObject fixture, String fixtureType) {
    this.ip = fixture.getString("IP", null);
    this.fixtureId = fixture.getInt("id", NO_FIXTURE_ID);
    this.nextFixtureId = fixture.getInt("child", NO_FIXTURE_ID);
    this.channel = fixtureType.equals(CHANNEL_ZERO) ? 0 : 4;
    
    // Load matrix values
    JSONArray matrixArr = fixture.getJSONArray("Matrix");
    float[] m = new float[16];
    for (int mi = 0; mi < m.length; ++mi) {
      m[mi] = matrixArr.getFloat(mi);
    }
    
    // Construct matrix converted into LX space
    this.matrix = new LXMatrix()
    .scaleX(-1)
    .scale(INCHES_PER_METER * INCHES)
    .multiply(
      // NOTE: stellar indexes matrix vertically
      m[0], m[4], m[8],  m[12],
      m[1], m[5], m[9],  m[13],
      m[2], m[6], m[10], m[14],
      m[3], m[7], m[11], m[15]
    )
    .scale(METERS_PER_INCH / INCHES)
    .translate(0, ASSEMBLAGE_Y_OFFSET, 0);
  }
}

public static class Tree extends LXModel {
  
  public enum ModelMode {
    MAJOR_LIMBS,
    STELLAR_IMPORT,
    UNIFORM_BRANCHES
  }
  
  public static final float TRUNK_DIAMETER = 3*FEET;
  public static final float LIMB_HEIGHT = 10*FEET;
  public static final int NUM_LIMBS = 12;
  
  public final List<Limb> limbs;
  public final List<Branch> branches;
  public final List<LeafAssemblage> assemblages;
  public final List<Leaf> leaves;
  
  public Tree(ModelMode mode) {
    super(new Fixture(mode));
    Fixture f = (Fixture) this.fixtures.get(0);
    this.branches = Collections.unmodifiableList(f.branches);
    this.limbs = Collections.unmodifiableList(f.limbs);
        
    // Collect up all the leaves for top-level reference
    final List<Leaf> leaves = new ArrayList<Leaf>();
    final List<LeafAssemblage> assemblages = new ArrayList<LeafAssemblage>(f.assemblages);
    for (Branch branch : this.branches) {
      for (LeafAssemblage assemblage : branch.assemblages) {
        assemblages.add(assemblage);
      }
    }
    for (LeafAssemblage assemblage : assemblages) {
      for (Leaf leaf : assemblage.leaves) {
        leaves.add(leaf);
      }
    }
    this.assemblages = Collections.unmodifiableList(assemblages);
    this.leaves = Collections.unmodifiableList(leaves);
  }

  private static class Fixture extends LXAbstractFixture {
    
    private final List<Branch> branches = new ArrayList<Branch>();
    private final List<LeafAssemblage> assemblages = new ArrayList<LeafAssemblage>();
    private final List<Limb> limbs = new ArrayList<Limb>();
    
    Fixture(ModelMode mode) {
      if (mode == ModelMode.STELLAR_IMPORT) {
                
        // Load up the Stellar export file
        JSONObject assemblages = applet.loadJSONObject(STELLAR_FILE);        
        JSONArray fixtures = assemblages.getJSONArray("Fixtures");
        
        // Load up all of the fixtures and index them by ID
        Map<Integer, StellarFixtureConfig> fixtureMap = new HashMap<Integer, StellarFixtureConfig>();
        for (int fi = 0; fi < fixtures.size(); ++fi) {
          JSONObject fixtureObj = fixtures.getJSONObject(fi);
          String fixtureType = fixtureObj.getString("FixtureType");
          if (!fixtureType.equals(StellarFixtureConfig.CHANNEL_ZERO) && !fixtureType.equals(StellarFixtureConfig.CHANNEL_FOUR)) {
            println("Skipping unknown Stellar Fixture type: " + fixtureType);
            continue;
          }
          // Make a fixture object, add to the list
          StellarFixtureConfig fixture = new StellarFixtureConfig(fixtureObj, fixtureType);
          fixtureMap.put(fixture.fixtureId, fixture);
        }
        
        // Now, take a pass and construct a map of branches
        Map<String, StellarBranchConfig> branchMap = new HashMap<String, StellarBranchConfig>();
        for (StellarFixtureConfig fixture : fixtureMap.values()) {
          if (fixture.ip != null) {
            // Find the branch for this IP address
            StellarBranchConfig branch = branchMap.get(fixture.ip);
            if (branch == null) {
              // First time we've seen it, construct one
              branch = new StellarBranchConfig(fixture.ip);
              branchMap.put(fixture.ip, branch);
            }
            // Load the base channel for this branch
            int channel = fixture.channel;
            branch.channels[channel] = fixture.matrix;
            
            // Traverse next fixture ID for other fixtures in this chain and
            // assemble them up into branches
            int nextFixtureId = fixture.nextFixtureId;
            while (nextFixtureId != StellarFixtureConfig.NO_FIXTURE_ID) {
              StellarFixtureConfig nextFixture = fixtureMap.get(nextFixtureId);
              if (nextFixture == null) {
                println("No fixture found for NextFixtureId: " + nextFixtureId);
                break;
              }
              if (++channel >= branch.channels.length) {
                println("Too many channels were found in fixture chain: " + branch.ip);
                break;
              }
              branch.channels[channel] = nextFixture.matrix;
              nextFixtureId = nextFixture.nextFixtureId;
            }
          }
        }

        // Okay, we've built up the whole set of branch controllers and we have
        // them organized by their IP addresses, now we finally add them to the model
        for (StellarBranchConfig branchConfig : branchMap.values()) {
          addBranch(branchConfig);
        }
        
        println("Stellar import done.");
        
      } else if (mode == ModelMode.UNIFORM_BRANCHES) {
        for (int ai = 0; ai < 14; ++ai) {
          for (int ei = 0; ei < 14; ++ ei) {
            float azimuth = (ai + (ei % 2) * .5) * TWO_PI / 13;
            float elevation = ei * HALF_PI / 13;
            float radius = 12*FEET;
            float x = radius * cos(azimuth) * cos(elevation);
            float z = radius * sin(azimuth) * cos(elevation);
            float y = radius * sin(elevation);
            addBranch(new Branch.Orientation(x, y, z, azimuth, elevation, TWO_PI * (float) Math.random()));
          }
        }
      } else {
        // Lowest layer of major limbs
        addLimb(0.0*FT, 0.1 * TWO_PI/6, Limb.Size.FULL);
        addLimb(1.0*FT, 1.2 * TWO_PI/6, Limb.Size.FULL);
        addLimb(3.0*FT, 1.9 * TWO_PI/6, Limb.Size.FULL);
        addLimb(1.7*FT, 2.1 * TWO_PI/6, Limb.Size.FULL);
        addLimb(1.2*FT, 2.9 * TWO_PI/6, Limb.Size.FULL);
        addLimb(0.8*FT, 4.1 * TWO_PI/6, Limb.Size.FULL);
        addLimb(2.4*FT, 4.9 * TWO_PI/6, Limb.Size.FULL);
        
        // Medium layer of limbs
        addLimb(6.0*FT, 0.4 * TWO_PI/6, Limb.Size.MEDIUM);
        addLimb(5.4*FT, 1.5 * TWO_PI/6, Limb.Size.MEDIUM);
        addLimb(4.2*FT, 3.4 * TWO_PI/6, Limb.Size.MEDIUM);
        addLimb(5.9*FT, 4.9 * TWO_PI/6, Limb.Size.MEDIUM);
        
        // We probably don't have this many...
        // addLimb(6.3*FT, 5.3 * TWO_PI/6, Limb.Size.MEDIUM);
        
        // A couple small top limbs
        // addLimb(7*FT, .3 * TWO_PI/6, Limb.Size.SMALL);
        // addLimb(7*FT, 3.1 * TWO_PI/6, Limb.Size.SMALL);
      }
    }
    
    private void addLimb(float y, float azimuth, Limb.Size size) {
      Limb limb = new Limb(y, azimuth, size);
      this.limbs.add(limb);
      addPoints(limb);
      for (Branch branch : limb.branches) {
        this.branches.add(branch);
      }
    }
    
    private void addAssemblage(LXTransform t) {
      addAssemblage(new LeafAssemblage(0, t));
    }
    
    private void addAssemblage(LeafAssemblage assemblage) {
      this.assemblages.add(assemblage);
      addPoints(assemblage);
    }
    
    private void addBranch(StellarBranchConfig branchConfig) {
      addBranch(new Branch(branchConfig));
    }
    
    private void addBranch(Branch.Orientation orientation) {
      addBranch(new Branch(orientation));
    }
    
    private void addBranch(Branch branch) {
      this.branches.add(branch);
      addPoints(branch);
    }
  }
}

public static class Limb extends LXModel {
  public enum Size {
    FULL,
    MEDIUM,
    SMALL
  };
  
  public static class Section {
    public final float radius;
    public final float len;
    public final float bend;
    
    public Section(float radius, float len, float bend) {
      this.radius = radius;
      this.len = len;
      this.bend = bend;
    }
  }
  
  public final static Section SECTION_1 = new Section(4.6875*IN, 4*FT, 0);
  public final static Section SECTION_2 = new Section(3.75*IN, 4*FT, 0);
  public final static Section SECTION_3 = new Section(3.75*IN, 4*FT, PI/6);
  public final static Section SECTION_4 = new Section(3.75*IN, 8*FT, PI/6);
  
  public final List<Branch> branches;
  
  public final float y;
  public final float azimuth;
  public final Size size;
  
  private static final float Y_BASE = -Tree.LIMB_HEIGHT + 5*FT; 
  
  public Limb(float y, float azimuth, Size size) {
    super(new Fixture(y + Y_BASE, azimuth, size));
    this.y = y + Y_BASE;
    this.azimuth = azimuth;
    this.size = size;
    Fixture f = (Fixture) this.fixtures.get(0);
    this.branches = Collections.unmodifiableList(f.branches);
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private final List<Branch> branches = new ArrayList<Branch>();
    
    Fixture(float y, float azimuth, Size size) {
      LXTransform t = new LXTransform();
      t.translate(0, y, 0);
      t.rotateY(HALF_PI - azimuth);
      t.rotateX(HALF_PI - PI/12);
      if (size == Size.FULL) {
        t.translate(0, SECTION_1.len, 0);
      }
      if (size != Size.SMALL) {
        t.translate(0, SECTION_2.len, 0);
      }
      t.rotateX(-PI/6);
      t.translate(0, SECTION_3.len);
      t.rotateX(-PI/6);
      
      // Branch S.2 (3)
      t.push();
      t.rotateX(PI/4);
      addBranchCluster(t, azimuth, -PI/8);
      t.pop();
      
      t.translate(0, SECTION_4.len);
      
      // Double-branch S.2 (12)      
      // First part (left)
      t.push();
      t.rotateY(-PI/3);
      t.rotateX(PI/4);
      addBranchCluster(t, azimuth + PI/3, -PI/6);
      t.pop();
      
      // Second part (right)
      t.push();
      t.rotateY(PI/3);
      t.rotateX(PI/4);
      addBranchCluster(t, azimuth - PI/3, PI/8);
      t.pop();
    }
    
    private void addBranchCluster(LXTransform t, float azimuth, float baseElevation) {
      // Loose interpretation of Branch S.2 (3)
      t.translate(0, 2*FT, 0);
      addBranch(t, azimuth, PI/3, baseElevation);
      t.translate(0, .5*FT, 0);
      addBranch(t, azimuth, -PI/3, baseElevation);
      t.translate(0, .5*FT, 0);
      addBranch(t, azimuth, PI/3, baseElevation);
      t.translate(0, .5*FT, 0);
      addBranch(t, azimuth, -PI/3, baseElevation);
      t.translate(0, .5*FT, 0);
      addBranch(t, azimuth, PI/3, baseElevation);
    }
    
    private void addBranch(LXTransform t, float azimuth, float offset, float baseElevation) {
      t.push();
      t.rotateZ(-offset);
      t.translate(0, 1*FT, 0);
      Branch branch = new Branch(new Branch.Orientation(
        t.x(),
        t.y(),
        t.z(),
        azimuth + offset,
        baseElevation + HALF_PI * (float) Math.random(),
        TWO_PI * (float) Math.random()
      ));
      addPoints(branch);
      this.branches.add(branch);
      t.pop();
    }
  }
}

/**
 * A branch is mounted on a major limb and houses many
 * leaf assemblages. This class is oriented in the x-y
 * plane with the branch pointing "upwards" in the y-axis.
 *
 * Leaf assemblages shoot off the left and right sides
 * as well as one out the top.
 */
public static class Branch extends LXModel {
  public static final int NUM_ASSEMBLAGES = 8;
  public static final int NUM_LEAVES = NUM_ASSEMBLAGES * LeafAssemblage.NUM_LEAVES;
  public static final int NUM_LEDS = NUM_ASSEMBLAGES * LeafAssemblage.NUM_LEDS;
  public static final float LENGTH = 6*FEET;
  public static final float WIDTH = 7*FEET;
  
  public static class Orientation {
    
    // Base of the branch, in global space
    public final float x;
    public final float y;
    public final float z;
    
    // Azimuth and elevation of branch's normal vector (the direction it points)
    public final float azimuth;
    public final float elevation;
    
    // Tilt of the branch about its normal (think of the branch doing a "barrel roll") 
    public final float tilt;
    
    public Orientation(float x, float y, float z, float azimuth, float elevation, float tilt) {
      this.x = x;
      this.y = y;
      this.z = z;
      this.azimuth = azimuth;
      this.elevation = elevation;
      this.tilt = tilt;
    }
  }
  
  // Orientation of this branch
  public final Orientation orientation;
  
  // IP address of this branch, if known
  public final String ip;
    
  public final List<LeafAssemblage> assemblages;
  public final List<Leaf> leaves;
  
  // Position of the branch in global space
  public final float x;
  public final float y;
  public final float z;
  
  // Azimuth and elevation of the branch in global space
  public final float azimuth;
  public final float elevation;
   
  private static final float RIGHT_THETA = -QUARTER_PI;
  private static final float LEFT_THETA = QUARTER_PI;
  
  private static final float RIGHT_OFFSET = 12*IN;
  private static final float LEFT_OFFSET = -12*IN;
  
  // Assemblage positions are relative to an assemblage
  // facing upwards. Each leaf assemblage 
  public static final LeafAssemblage.Orientation[] ASSEMBLAGES = {
    // Right side bottom to top
    new LeafAssemblage.Orientation(RIGHT_OFFSET, 2*IN, RIGHT_THETA),
    new LeafAssemblage.Orientation(RIGHT_OFFSET, 14*IN, RIGHT_THETA),
    new LeafAssemblage.Orientation(RIGHT_OFFSET, 26*IN, RIGHT_THETA),
    new LeafAssemblage.Orientation(RIGHT_OFFSET, 38*IN, RIGHT_THETA),
    
    // End node
    new LeafAssemblage.Orientation(0, 44*IN, 0),
    
    // Left side top to bottom
    new LeafAssemblage.Orientation(LEFT_OFFSET, 32*IN, LEFT_THETA),
    new LeafAssemblage.Orientation(LEFT_OFFSET, 20*IN, LEFT_THETA),
    new LeafAssemblage.Orientation(LEFT_OFFSET, 8*IN, LEFT_THETA)
  };
      
  private static LXTransform getTransform(Orientation orientation) {
    return new LXTransform()
      .translate(orientation.x, orientation.y, orientation.z)
      .rotateY(HALF_PI - orientation.azimuth)
      .rotateX(HALF_PI - orientation.elevation)
      .rotateY(orientation.tilt);      
  }
      
  public Branch(Orientation orientation) {
    this(getTransform(orientation), orientation);
  }
  
  public Branch(StellarBranchConfig branchConfig) {
    super(new Fixture(branchConfig));
    this.ip = branchConfig.ip;
    this.orientation = null;
    Fixture f = (Fixture) this.fixtures.get(0);
    this.assemblages = Collections.unmodifiableList(f.assemblages);
    List<Leaf> leaves = new ArrayList<Leaf>();
    for (LeafAssemblage assemblage : this.assemblages) {
      for (Leaf leaf : assemblage.leaves) {
        leaves.add(leaf);
      }
    }
    this.leaves = Collections.unmodifiableList(leaves);
    this.x = this.leaves.get(0).x;
    this.y = this.leaves.get(0).y;
    this.z = this.leaves.get(0).z;
    this.azimuth = atan2(this.z, this.x);
    this.elevation = atan2(this.y, dist(0, 0, this.x, this.z));  
  }
  
  public Branch(LXTransform t) {
    // TODO(mcslee): compute azim/elev/tilt from matrix?
    this(t, new Orientation(t.x(), t.y(), t.z(), 0, 0, 0));
  }
  
  public Branch(LXTransform t, Orientation orientation) {
    super(new Fixture(t));
    this.ip = null;
    this.orientation = orientation;
    this.x = t.x();
    this.y = t.y();
    this.z = t.z();
    this.azimuth = atan2(this.z, this.x);
    this.elevation = atan2(this.y, dist(0, 0, this.x, this.z));
    Fixture f = (Fixture) this.fixtures.get(0);
    this.assemblages = Collections.unmodifiableList(f.assemblages);
    List<Leaf> leaves = new ArrayList<Leaf>();
    for (LeafAssemblage assemblage : this.assemblages) {
      for (Leaf leaf : assemblage.leaves) {
        leaves.add(leaf);
      }
    }
    this.leaves = Collections.unmodifiableList(leaves);
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private final List<LeafAssemblage> assemblages = new ArrayList<LeafAssemblage>();
    
    Fixture(StellarBranchConfig branchConfig) {
      for (int i = 0; i < branchConfig.channels.length; ++i) {
        LXMatrix matrix = branchConfig.channels[i];
        if (matrix != null) {
          LeafAssemblage assemblage = new LeafAssemblage(i, new LXTransform(matrix));
          this.assemblages.add(assemblage);
          addPoints(assemblage);
        }
      }
    }
    
    Fixture(LXTransform t) {
      int channel = 0;
      for (LeafAssemblage.Orientation assemblage : ASSEMBLAGES) {
        t.push();
        t.translate(assemblage.x, assemblage.y, 0);
        t.rotateZ(assemblage.theta);
        t.rotateY(assemblage.tilt);
        LeafAssemblage leafAssemblage = new LeafAssemblage(channel++, t, assemblage);
        this.assemblages.add(leafAssemblage);
        addPoints(leafAssemblage);
        t.pop();
      }
    }
  }
}

/**
 * An assemblage is a modular fixture with multiple leaves.
 */
public static class LeafAssemblage extends LXModel {
  
  public static final int NUM_LEAVES = 15;
  public static final int NUM_LEDS = NUM_LEAVES * Leaf.NUM_LEDS;
  
  public static final float LENGTH = 26*IN;
  public static final float WIDTH = 24*IN;

  // Orientation of a leaf assemblage, relative to parent branch
  public static class Orientation {
    
    // Offset from base of branch, y-axis points "up" the branch
    public final float x;
    public final float y;
    
    // Rotation in the x-y plane, relative to the branch
    // wwhere y is pointing "up" the branch 
    public final float theta;
    
    // Tilt of the leaf assemblage about the axis of its normal
    // e.g. a "barrel roll" on the leaf assemblage
    public final float tilt;
    
    Orientation(float x, float y, float theta) {
      this.x = x;
      this.y = y;
      this.theta = theta;
      this.tilt = -QUARTER_PI + HALF_PI * (float) Math.random();
    }
  }

  // These positions indicate how a leaf is positioned on an assemblage,
  // assuming the assemblage is facing "up", the main stem is at (0, 0)
  // Positive x-values move to the right, and positive y-values move
  // up the branch, away from the base stem.
  //
  // Third argument is the rotation of the leaf on the x-y plane, 0
  // is the leaf pointing "up", HALF_PI is pointing to the left,
  // -HALF_PI is pointing to the right, etc.
  public static final Leaf.Orientation[] LEAVES = {    
    new Leaf.Orientation(0,  4.5*IN, -1.7*IN, -HALF_PI - QUARTER_PI), // A
    new Leaf.Orientation(1,  5.5*IN,    0*IN, -HALF_PI), // B
    new Leaf.Orientation(2,  2.0*IN,  3.5*IN, -HALF_PI + QUARTER_PI), // C
    new Leaf.Orientation(3,  3.5*IN,  7.5*IN, -HALF_PI), // D
    new Leaf.Orientation(4,  4.0*IN, 11.2*IN, -HALF_PI), // E
    new Leaf.Orientation(5,  3.0*IN,  9.5*IN, -HALF_PI + QUARTER_PI), // F
    new Leaf.Orientation(6,  3.5*IN, 12.7*IN, -HALF_PI + QUARTER_PI), // G
    new Leaf.Orientation(7,  0.0*IN, 13.5*IN, 0), // H
    null, // I
    null, // J
    null, // K
    null, // L
    null, // M
    null, // N
    null, // O
  };
  
  static {
    // Make sure we didn't bork that array editing manually!
    assert(LEAVES.length == NUM_LEAVES);
    
    // The last seven leaves are just inverse of the first about
    // the y-axis.
    for (int i = 0; i < 7; ++i) {
      Leaf.Orientation thisLeaf = LEAVES[i];
      int index = LEAVES.length - 1 - i; 
      LEAVES[index] = new Leaf.Orientation(index, -thisLeaf.x, thisLeaf.y, -thisLeaf.theta);
    }
  }
  
  public final Orientation orientation;
  public final List<Leaf> leaves;
  public final int channel;
  
  public LeafAssemblage(int channel, LXTransform t) {
    this(channel, t, new Orientation(0, 0, 0));
  }
  
  public LeafAssemblage(int channel, LXTransform t, Orientation orientation) {
    super(new Fixture(t));
    Fixture f = (Fixture) this.fixtures.get(0);
    this.channel = channel;
    this.leaves = Collections.unmodifiableList(f.leaves);
    this.orientation = orientation;
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private final List<Leaf> leaves = new ArrayList<Leaf>();
    
    Fixture(LXTransform t) {
      t.push();
      // TODO(mcslee): do we want this?
      t.translate(0, 5*INCHES, 0);
      for (int i = 0; i < NUM_LEAVES; ++i) {
        Leaf.Orientation leafOrientation = LEAVES[i];
        t.push();
        t.translate(leafOrientation.x, leafOrientation.y, (i % 3) * (.1*INCHES));
        t.rotateZ(leafOrientation.theta);
        Leaf leaf = new Leaf(t, leafOrientation);
        this.leaves.add(leaf);
        addPoints(leaf);
        t.pop();
      }
      t.pop();
    }
  }
}

/**
 * The base addressable fixture, a Leaf with LEDs embedded inside.
 * Currently modeled as a single point. Room for improvement!
 */
public static class Leaf extends LXModel {
  public static final int NUM_LEDS = 7;
  public static final float LED_OFFSET = .75*IN;
  public static final float LED_SPACING = 1.3*IN;
  public static final float WIDTH = 4.75*IN; 
  public static final float LENGTH = 6.5*IN;
  
  // Orientation of a leaf relative to leaf assemblage
  public static class Orientation {
    
    public final int index;
    
    // X-Y position relative to leaf assemblage base
    // y-axis pointing "up" the leaf assemblage 
    public final float x;
    public final float y;
    
    // Rotation about X-Y plane relative to parent assemblage
    public final float theta;
    
    // Tilt of the individual leaf
    public final float tilt;
    
    Orientation(int index, float x, float y, float theta) {
      this.index = index;
      this.x = x;
      this.y = y;
      this.theta = theta;
      this.tilt = -QUARTER_PI + HALF_PI * (float) Math.random();
    }
  }
  
  public final LXPoint point;
  
  public final float x;
  public final float y;
  public final float z;
  
  public final LXVector[] coords = new LXVector[4];
  
  public final Orientation orientation;
  
  public Leaf() {
    this(new LXTransform());
  }
  
  public Leaf(LXTransform t) {
    this(t, new Orientation(0, 0, 0, 0));
  }
  
  public Leaf(LXTransform t, Orientation orientation) {
    super(new Fixture(t, orientation));
    this.orientation = orientation;
    this.x = t.x();
    this.y = t.y();
    this.z = t.z();
    this.point = this.points[0];
    
    // Precompute boundary coordinates for faster rendering, these
    // can be dumped into a VBO for a shader.
    t.push();
    t.translate(-WIDTH/2, 0);
    this.coords[0] = t.vector();
    t.translate(0, LENGTH);
    this.coords[1] = t.vector();
    t.translate(WIDTH, 0);
    this.coords[2] = t.vector();
    t.translate(0, -LENGTH);
    this.coords[3] = t.vector();
    t.pop();
  }
  
  private static class Fixture extends LXAbstractFixture {
    Fixture(LXTransform t, Orientation orientation) {
      t.push();
      t.translate(.1*INCHES, LED_OFFSET, 0);
      addPoint(new LXPoint(t));
      t.translate(0, LED_SPACING, 0);
      addPoint(new LXPoint(t));
      t.translate(0, LED_SPACING, 0);
      addPoint(new LXPoint(t));
      t.translate(-.1*INCHES, LED_SPACING, 0);
      addPoint(new LXPoint(t));
      t.translate(-.1*INCHES, -LED_SPACING, 0);
      addPoint(new LXPoint(t));
      t.translate(0, -LED_SPACING, 0);
      addPoint(new LXPoint(t));
      t.translate(0, -LED_SPACING, 0);
      addPoint(new LXPoint(t));
      t.pop();
    }
  }
}

// Cheap mockup of a tree canopy until we get a better model
// based upon actual mechanical drawings and fabricated dimensions.
// This one just estimates a cloud of points distributed across
// a hemisphere. Left here for reference.
public static class Hemisphere extends LXModel {
  
  public static final float NUM_POINTS = 25000;
  public static final float INNER_RADIUS = 33*FEET;
  public static final float OUTER_RADIUS = 36*FEET;
  
  public Hemisphere() {
    super(new Fixture());
  }
  
  private static class Fixture extends LXAbstractFixture {
    Fixture() {
      for (int i = 0; i < NUM_POINTS; ++i) {
        float azimuth = (98752234*i + 4871433);
        float elevation = (i*234.351234) % HALF_PI;
        float radius = INNER_RADIUS + (i * 7*INCHES) % (OUTER_RADIUS - INNER_RADIUS);
        double x = radius * Math.cos(azimuth) * Math.cos(elevation);
        double z = radius * Math.sin(azimuth) * Math.cos(elevation);
        double y = radius * Math.sin(elevation);
        addPoint(new LXPoint(x, y, z));
      }
    }
  }
}