import heronarts.lx.model.*;
import java.util.Collections;
import java.util.List;

Tree buildTree() {
  return new Tree();
}

// Cheap mockup of a tree canopy until we get a better model
// based upon actual mechanical drawings and fabricated dimensions.
// This one just estimates a cloud of points distributed across
// a hemisphere.
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

/**
 * Eventually this will be the real tree model. A hierarchical
 * model that represents the modular structure of limbs and
 * assemblages of branches and leaves.
 */
public static class Tree extends LXModel {
  
  public static final float TRUNK_DIAMETER = 3*FEET;
  public static final float LIMB_HEIGHT = 18*FEET;
  public static final int NUM_LIMBS = 12;
  
  public final List<Limb> limbs;
  public final List<Branch> branches;
  public final List<Leaf> leaves;
  
  public Tree() {
    this(new LXTransform());
  }
  
  public Tree(LXTransform t) {
    super(new Fixture(t));
    Fixture f = (Fixture) this.fixtures.get(0);
    this.limbs = Collections.unmodifiableList(f.limbs);
    this.branches = Collections.unmodifiableList(f.branches);
    
    // Collect up all the leaves for top-level reference
    final List<Leaf> leaves = new ArrayList<Leaf>();
    for (Branch branch : this.branches) {
      for (LeafAssemblage assemblage : branch.assemblages) {
        for (Leaf leaf : assemblage.leaves) {
          leaves.add(leaf);
        }
      }
    }
    this.leaves = Collections.unmodifiableList(leaves);
  }
  
  public static class BranchPosition {
    
    public final float azimuth;
    public final float elevation;
    public final float radius;
    public final float tilt;
    
    public BranchPosition(float azimuth, float elevation, float radius) {
      this.azimuth = azimuth;
      this.elevation = elevation;
      this.radius = radius;
      this.tilt = TWO_PI * (float) Math.random();
    }
  }

  private static class Fixture extends LXAbstractFixture {
    
    private final List<Limb> limbs = new ArrayList<Limb>();
    private final List<Branch> branches = new ArrayList<Branch>();
    
    Fixture(LXTransform t) {
      // addBranch(t, new BranchPosition(QUARTER_PI, QUARTER_PI, 12*FEET));
      for (int ai = 0; ai < 14; ++ai) {
        for (int ei = 0; ei < 14; ++ ei) {
          float azimuth = (ai + (ei % 2) * .5) * TWO_PI / 13;
          float elevation = ei * HALF_PI / 13;
          float radius = 12*FEET;
          addBranch(t, new BranchPosition(azimuth, elevation, radius));
        }
      }
    }
    
    private void addBranch(LXTransform t, BranchPosition position) {
      t.push();
      t.rotateY(position.azimuth);
      t.rotateZ(HALF_PI-position.elevation);
      t.translate(0, position.radius, 0);
      t.rotateY(position.tilt);
      Branch branch = new Branch(t, position);
      this.branches.add(branch);
      addPoints(branch);
      t.pop();
    }
  }
}

/**
 * A limb is a major radial structure coming off the trunk of the
 * tree, which supports many branches.
 */
public static class Limb extends LXModel {
  
  public static final float RADIUS = 16.5*FEET;
  public static final int NUM_BRANCHES = 17;
    
  public final List<Branch> branches;
  
  public Limb(LXTransform t) {
    super(new Fixture(t));
    Fixture f = (Fixture) this.fixtures.get(0);
    this.branches = Collections.unmodifiableList(f.branches);
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private final List<Branch> branches = new ArrayList<Branch>();
    
    Fixture(LXTransform t) {
      t.push();
      t.translate(0, 0, RADIUS); // move out to the end of the limb
      for (int i = 0; i < NUM_BRANCHES; ++i) {
        t.push();
        
        float azimuth = (float) (-HALF_PI + Math.random() * PI);
        t.rotateY(azimuth);
        float elevation = (float) (HALF_PI - Math.random() * PI/6);
        t.rotateX(elevation);
        t.rotateZ(Math.random() * TWO_PI);
        t.translate(0, 0, (float) Math.random() * 10*INCHES);
        Branch branch = new Branch(t);
        this.branches.add(branch);
        addPoints(branch);
        
        t.pop();
        t.translate(0, 0, -2*INCHES);
      }
      t.pop();
    }
  }
}

/**
 * A branch is mounted on a major limb and houses many
 * leaf assemblages.
 */
public static class Branch extends LXModel {
  public static final int NUM_ASSEMBLAGES = 8;
  public static final float LENGTH = 6*FEET;
  public static final float WIDTH = 7*FEET;
  
  public final List<LeafAssemblage> assemblages;
  public final float x;
  public final float y;
  public final float z;
  public final Tree.BranchPosition position;
  
  public static class AssemblagePosition {
    public final float x;
    public final float y;
    public final float theta;
    public final float tilt;
    
    AssemblagePosition(float x, float y, float theta) {
      this.x = x;
      this.y = y;
      this.theta = theta;
      this.tilt = -QUARTER_PI + HALF_PI * (float) Math.random();
    }
  }
  
  private static final float RIGHT_THETA = QUARTER_PI;
  private static final float LEFT_THETA = -QUARTER_PI;
  
  private static final float RIGHT_OFFSET = 12*IN;
  private static final float LEFT_OFFSET = -12*IN;
  
  // Assemblage positions are relative to an assemblage
  // facing upwards. Each leaf assemblage 
  public static final AssemblagePosition[] ASSEMBLAGE_POSITIONS = {
    // Right side bottom to top
    new AssemblagePosition(RIGHT_OFFSET, 2*IN, RIGHT_THETA),
    new AssemblagePosition(RIGHT_OFFSET, 14*IN, RIGHT_THETA),
    new AssemblagePosition(RIGHT_OFFSET, 26*IN, RIGHT_THETA),
    new AssemblagePosition(RIGHT_OFFSET, 38*IN, RIGHT_THETA),
    
    // End node
    new AssemblagePosition(0, 44*IN, 0),
    
    // Left side top to bottom
    new AssemblagePosition(LEFT_OFFSET, 32*IN, LEFT_THETA),
    new AssemblagePosition(LEFT_OFFSET, 20*IN, LEFT_THETA),
    new AssemblagePosition(LEFT_OFFSET, 8*IN, LEFT_THETA)
  };
    
  public Branch(LXTransform t) {
    this(t, new Tree.BranchPosition(0, 0, 0));
  }
    
  public Branch(LXTransform t, Tree.BranchPosition position) {
    super(new Fixture(t));
    this.x = t.x();
    this.y = t.y();
    this.z = t.z();
    this.position = position;
    Fixture f = (Fixture) this.fixtures.get(0);
    this.assemblages = Collections.unmodifiableList(f.assemblages);
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private final List<LeafAssemblage> assemblages = new ArrayList<LeafAssemblage>();
    
    Fixture(LXTransform t) {
      for (AssemblagePosition position : ASSEMBLAGE_POSITIONS) {
        t.push();
        t.translate(position.x, position.y, 0);
        t.rotateZ(position.theta);
        t.rotateY(position.tilt);
        LeafAssemblage leafAssemblage = new LeafAssemblage(t, position);
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

  public static class LeafPosition {
    public final float x;
    public final float y;
    public final float theta;
    public final float tilt;
    
    LeafPosition(float x, float y, float theta) {
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
  // is the leaf pointing "up", HALF_PI is pointing to the right,
  // -HALF_PI is pointing to the left, etc.
  public static final LeafPosition[] LEAF_POSITIONS = {    
    new LeafPosition( 6.4*IN,  8.8*IN, HALF_PI + QUARTER_PI), // A
    new LeafPosition( 6.9*IN, 10.0*IN, HALF_PI), // B
    new LeafPosition(10.4*IN, 14.7*IN, HALF_PI + .318), // C
    new LeafPosition(10.0*IN, 16.1*IN, .900), // D
    new LeafPosition( 1.2*IN, 13.9*IN, 1.08), // E
    new LeafPosition( 3.5*IN, 22.2*IN, HALF_PI + .2), // F
    new LeafPosition( 2.9*IN, 23.3*IN, .828), // G
    new LeafPosition( 0.0*IN, 23.9*IN, 0), // H
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
    assert(LEAF_POSITIONS.length == NUM_LEAVES);
    
    // The last seven leaves are just inverse of the first about
    // the y-axis.
    for (int i = 0; i < 7; ++i) {
      LeafPosition thisLeaf = LEAF_POSITIONS[i];
      LEAF_POSITIONS[LEAF_POSITIONS.length - 1 - i] =
        new LeafPosition(-thisLeaf.x, thisLeaf.y, -thisLeaf.theta);
    }
  }
  
  public static final float LENGTH = 28*IN;
  public static final float WIDTH = 28*IN;
  
  public final Branch.AssemblagePosition position;
  public final List<Leaf> leaves;
  
  public LeafAssemblage(LXTransform t, Branch.AssemblagePosition position) {
    super(new Fixture(t));
    Fixture f = (Fixture) this.fixtures.get(0);
    this.leaves = Collections.unmodifiableList(f.leaves);
    this.position = position;
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    private final List<Leaf> leaves = new ArrayList<Leaf>();
    
    Fixture(LXTransform t) {
      for (int i = 0; i < NUM_LEAVES; ++i) {
        LeafPosition leafPosition = LEAF_POSITIONS[i];
        t.push();
        t.translate(leafPosition.x, leafPosition.y, 0);
        t.rotateZ(leafPosition.theta);
        Leaf leaf = new Leaf(t, leafPosition);
        this.leaves.add(leaf);
        addPoints(leaf);
        t.pop();
      } 

    }
  }
}

/**
 * The base addressable fixture, a Leaf with LEDs embedded inside.
 * Currently modeled as a single point. Room for improvement!
 */
public static class Leaf extends LXModel {
  public static final int NUM_LEDS = 7;
  public static final float WIDTH = 5*IN; 
  public static final float LENGTH = 6.5*IN;
  
  public final float x;
  public final float y;
  public final float z;
  
  public final LXVector[] coords = new LXVector[4];
  
  public final LeafAssemblage.LeafPosition position;
  
  public Leaf() {
    this(new LXTransform());
  }
  
  public Leaf(LXTransform t) {
    this(t, new LeafAssemblage.LeafPosition(0, 0, 0));
  }
  
  public Leaf(LXTransform t, LeafAssemblage.LeafPosition position) {
    super(new Fixture(t));
    this.position = position;
    this.x = t.x();
    this.y = t.y();
    this.z = t.z();
    
    // Precompute boundary coordinates for faster rendering
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
    Fixture(LXTransform t) {
      // TODO: do we model multiple LEDs here or not?
      addPoint(new LXPoint(t));
    }
  }
}