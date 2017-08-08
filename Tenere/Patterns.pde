public abstract class TenerePattern extends LXPattern {
  
  protected final Tree model;
  
  public TenerePattern(LX lx) {
    super(lx);
    this.model = (Tree) lx.model;
  }
  
  public abstract String getAuthor();
  
  public void onActive() {
    // TODO: report via OSC to blockchain
  }
  
  public void onInactive() {
    // TODO: report via OSC to blockchain
  }
}

public class White extends LXPattern {
  
  public final CompoundParameter h = new CompoundParameter("Hue", 0, 360);
  public final CompoundParameter s = new CompoundParameter("Sat", 0, 100);
  public final CompoundParameter b = new CompoundParameter("Brt", 100, 100);
  
  public White(LX lx) {
    super(lx);
    addParameter("h", this.h);
    addParameter("s", this.s);
    addParameter("b", this.b);
  }
  
  public void run(double deltaMs) {
    setColors(LXColor.hsb(this.h.getValue(), this.s.getValue(), this.b.getValue()));
  }
}

public class Borealis extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed =
    new CompoundParameter("Speed", .5, .01, 1);
  
  public final CompoundParameter scale =
    new CompoundParameter("Scale", .5, .1, 1);
  
  public final CompoundParameter spread =
    new CompoundParameter("Spread", 6, .1, 10);
  
  public final CompoundParameter base =
    new CompoundParameter("Base", .5, .2, 1);
  
  public Borealis(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("scale", this.scale);
    addParameter("spread", this.spread);
    addParameter("base", this.base);
  }
  
  private float yBasis = 0;
  
  public void run(double deltaMs) {
    this.yBasis -= deltaMs * .0005 * this.speed.getValuef();
    float scale = this.scale.getValuef();
    float spread = this.spread.getValuef();
    float base = .01 * this.base.getValuef();
    for (Leaf leaf : tree.leaves) {
      float nv = noise(
        scale * (base * leaf.point.rxz - spread * leaf.point.yn),
        leaf.point.yn + this.yBasis
      );
      setColor(leaf, LXColor.gray(constrain(-50 + 150 * nv, 0, 100)));
    }
  }
}

public class Clouds extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter thickness =
    new CompoundParameter("Thickness", 50, 100, 0)
    .setDescription("Thickness of the cloud formation");
  
  public final CompoundParameter xSpeed =
    new CompoundParameter("XSpd", 0, -1, 1)
    .setDescription("Motion along the X axis");

  public final CompoundParameter ySpeed =
    new CompoundParameter("YSpd", 0, -1, 1)
    .setDescription("Motion along the Y axis");
    
  public final CompoundParameter zSpeed =
    new CompoundParameter("ZSpd", 0, -1, 1)
    .setDescription("Motion along the Z axis");
    
  public final CompoundParameter scale = (CompoundParameter)
    new CompoundParameter("Scale", 3, .25, 10)
    .setDescription("Scale of the clouds")
    .setExponent(2);

  public final CompoundParameter xScale =
    new CompoundParameter("XScale", 0, 0, 10)
    .setDescription("Scale along the X axis");

  public final CompoundParameter yScale =
    new CompoundParameter("YScale", 0, 0, 10)
    .setDescription("Scale along the Y axis");
    
  public final CompoundParameter zScale =
    new CompoundParameter("ZScale", 0, 0, 10)
    .setDescription("Scale along the Z axis");
    
  private float xBasis = 0, yBasis = 0, zBasis = 0;
    
  public Clouds(LX lx) {
    super(lx);
    addParameter("thickness", this.thickness);
    addParameter("xSpeed", this.xSpeed);
    addParameter("ySpeed", this.ySpeed);
    addParameter("zSpeed", this.zSpeed);
    addParameter("scale", this.scale);
    addParameter("xScale", this.xScale);
    addParameter("yScale", this.yScale);
    addParameter("zScale", this.zScale);
  }

  private static final double MOTION = .0005;

  public void run(double deltaMs) {
    this.xBasis -= deltaMs * MOTION * this.xSpeed.getValuef();
    this.yBasis -= deltaMs * MOTION * this.ySpeed.getValuef();
    this.zBasis -= deltaMs * MOTION * this.zSpeed.getValuef();
    float thickness = this.thickness.getValuef();
    float scale = this.scale.getValuef();
    float xScale = this.xScale.getValuef();
    float yScale = this.yScale.getValuef();
    float zScale = this.zScale.getValuef();
    for (Leaf leaf : tree.leaves) {
      float nv = noise(
        (scale + leaf.point.xn * xScale) * leaf.point.xn + this.xBasis,
        (scale + leaf.point.yn * yScale) * leaf.point.yn + this.yBasis, 
        (scale + leaf.point.zn * zScale) * leaf.point.zn + this.zBasis
      );
      setColor(leaf, LXColor.gray(constrain(-thickness + (150 + thickness) * nv, 0, 100)));
    }
  }  
}

public class Scanner extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed =
    new CompoundParameter("Speed", .5, -1, 1)
    .setDescription("Speed that the plane moves at");
    
  public final CompoundParameter sharp = (CompoundParameter)
    new CompoundParameter("Sharp", 0, -50, 150)
    .setDescription("Sharpness of the falling plane")
    .setExponent(2);
    
  public final CompoundParameter xSlope = (CompoundParameter)
    new CompoundParameter("XSlope", 0, -1, 1)
    .setDescription("Slope on the X-axis");
    
  public final CompoundParameter zSlope = (CompoundParameter)
    new CompoundParameter("ZSlope", 0, -1, 1)
    .setDescription("Slope on the Z-axis");
  
  private float basis = 0;
  
  public Scanner(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("sharp", this.sharp);
    addParameter("xSlope", this.xSlope);
    addParameter("zSlope", this.zSlope);
  }
  
  public void run(double deltaMs) {
    float speed = this.speed.getValuef();
    speed = speed * speed * ((speed < 0) ? -1 : 1);
    float sharp = this.sharp.getValuef();
    float xSlope = this.xSlope.getValuef();
    float zSlope = this.zSlope.getValuef();
    this.basis = (float) (this.basis - .001 * speed * deltaMs) % 1.;
    for (Leaf leaf : model.leaves) {
      setColor(leaf, LXColor.gray(max(0, 50 - sharp + (50 + sharp) * LXUtils.trif(leaf.point.yn + this.basis + (leaf.point.xn-.5) * xSlope + (leaf.point.zn-.5) * zSlope))))  ;
    }
  }
}

public class Starlight extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  final static int MAX_STARS = 5000;
  final static int LEAVES_PER_STAR = 3;
  
  final LXUtils.LookupTable flicker = new LXUtils.LookupTable(360, new LXUtils.LookupTable.Function() {
    public float compute(int i, int tableSize) {
      return .5 - .5 * cos(i * TWO_PI / tableSize);
    }
  });
  
  public final CompoundParameter speed =
    new CompoundParameter("Speed", 3000, 9000, 300)
    .setDescription("Speed of the twinkling");
    
  public final CompoundParameter variance =
    new CompoundParameter("Variance", .5, 0, .9)
    .setDescription("Variance of the twinkling");    
  
  public final CompoundParameter numStars =
    new CompoundParameter("Num", 5000, 1000, MAX_STARS)
    .setDescription("Number of stars");
  
  private final Star[] stars = new Star[MAX_STARS];
    
  private final ArrayList<Leaf> shuffledLeaves;
    
  public Starlight(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("variance", this.variance);
    addParameter("numStars", this.numStars);
    this.shuffledLeaves = new ArrayList<Leaf>(model.leaves); 
    Collections.shuffle(this.shuffledLeaves);
    for (int i = 0; i < MAX_STARS; ++i) {
      this.stars[i] = new Star(i);
    }
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
    float numStars = this.numStars.getValuef();
    float speed = this.speed.getValuef();
    float variance = this.variance.getValuef();
    for (Star star : this.stars) {
      if (star.active) {
        star.run(deltaMs);
      } else if (star.num < numStars) {
        star.activate(speed, variance);
      }
    }
  }
  
  class Star {
    
    final int num;
    
    double period;
    float amplitude = 50;
    double accum = 0;
    boolean active = false;
    
    Star(int num) {
      this.num = num;
    }
    
    void activate(float speed, float variance) {
      this.period = max(400, speed * (1 + random(-variance, variance)));
      this.accum = 0;
      this.amplitude = random(20, 100);
      this.active = true;
    }
    
    void run(double deltaMs) {
      int c = LXColor.gray(this.amplitude * flicker.get(this.accum / this.period));
      for (int i = 0; i < LEAVES_PER_STAR; ++i) {
        setColor(shuffledLeaves.get(num * LEAVES_PER_STAR + i), c);
      }
      this.accum += deltaMs;
      if (this.accum > this.period) {
        this.active = false;
      }
    }
  }

}

public class Waves extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  final int NUM_LAYERS = 3;

  public final CompoundParameter rate = (CompoundParameter)
    new CompoundParameter("Rate", 6000, 48000, 2000)
    .setDescription("Rate of the of the wave motion")
    .setExponent(.3);

  public final CompoundParameter size =
    new CompoundParameter("Size", 4*FEET, 28*FEET)
    .setDescription("Width of the wave");
    
  public final CompoundParameter amp1 =
    new CompoundParameter("Amp1", .5, 2, .2)
    .setDescription("First modulation size");
    
  public final CompoundParameter amp2 =
    new CompoundParameter("Amp2", 1.4, 2, .2)
    .setDescription("Second modulation size");
    
  public final CompoundParameter amp3 =
    new CompoundParameter("Amp3", .5, 2, .2)
    .setDescription("Third modulation size");
    
  public final CompoundParameter len1 =
    new CompoundParameter("Len1", 1, 2, .2)
    .setDescription("First wavelength size");
    
  public final CompoundParameter len2 =
    new CompoundParameter("Len2", .8, 2, .2)
    .setDescription("Second wavelength size");
    
  public final CompoundParameter len3 =
    new CompoundParameter("Len3", 1.5, 2, .2)
    .setDescription("Third wavelength size");
    
  private final LXModulator phase =
    startModulator(new SawLFO(0, TWO_PI, rate));

  private final double[] bins = new double[512];

  public Waves(LX lx) {
    super(lx);
    addParameter("rate", this.rate);
    addParameter("size", this.size);
    addParameter("amp1", this.amp1);
    addParameter("amp2", this.amp2);
    addParameter("amp3", this.amp3);
    addParameter("len1", this.len1);
    addParameter("len2", this.len2);
    addParameter("len3", this.len3);
  }

  public void run(double deltaMs) {
    double phaseValue = phase.getValue();
    float amp1 = this.amp1.getValuef();
    float amp2 = this.amp2.getValuef();
    float amp3 = this.amp3.getValuef();
    float len1 = this.len1.getValuef();
    float len2 = this.len2.getValuef();
    float len3 = this.len3.getValuef();
    
    float falloff = 100 / size.getValuef();
    for (int i = 0; i < bins.length; ++i) {
      bins[i] = model.cy + model.yRange/2 * Math.sin(i * TWO_PI / bins.length + phaseValue);
    }
    for (Leaf leaf : tree.leaves) {
      int idx = Math.round((bins.length-1) * (len1 * leaf.point.xn)) % bins.length;
      int idx2 = Math.round((bins.length-1) * (len2 * (.2 + leaf.point.xn))) % bins.length;
      int idx3 = Math.round((bins.length-1) * (len2 * (1.7 - leaf.point.xn))) % bins.length; 
      
      float y1 = (float) bins[idx];
      float y2 = (float) bins[idx2];
      float y3 = (float) bins[idx3];
      
      float d1 = abs(leaf.y*amp1 - y1);
      float d2 = abs(leaf.y*amp2 - y2);
      float d3 = abs(leaf.y*amp3 - y3);
      
      float b = max(0, 100 - falloff * min(min(d1, d2), d3));      
      setColor(leaf, b > 0 ? LXColor.gray(b) : #000000);
    }
  }
}

public class Vortex extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  private final SinLFO xPos = new SinLFO(model.xMin, model.xMax, startModulator(
    new SinLFO(29000, 59000, 51000).randomBasis()
    ));

  private final SinLFO yPos = new SinLFO(model.yMin, model.yMax, startModulator(
    new SinLFO(35000, 44000, 57000).randomBasis()
    ));

  public final CompoundParameter vortexBase = new CompoundParameter("Base", 
    12*INCHES, 
    1*INCHES, 
    140*INCHES
    );

  public final CompoundParameter vortexMod = new CompoundParameter("Mod", 0, 120*INCHES);

  private final SinLFO vortexSize = new SinLFO(0, vortexMod, 19000);

  private final SawLFO pos = new SawLFO(0, 1, startModulator(
    new SinLFO(1000, 9000, 17000)
    ));

  private final SinLFO xSlope = new SinLFO(-1, 1, startModulator(
    new SinLFO(78000, 104000, 17000).randomBasis()
    ));

  private final SinLFO ySlope = new SinLFO(-1, 1, startModulator(
    new SinLFO(37000, 79000, 51000).randomBasis()
    ));

  private final SinLFO zSlope = new SinLFO(-.2, .2, startModulator(
    new SinLFO(47000, 91000, 53000).randomBasis()
    ));

  public Vortex(LX lx) {
    super(lx);
    addParameter(vortexBase);
    addParameter(vortexMod);
    startModulator(xPos.randomBasis());
    startModulator(yPos.randomBasis());
    startModulator(pos);
    startModulator(vortexSize);
    startModulator(xSlope);
    startModulator(ySlope);
    startModulator(zSlope);
  }

  public void run(double deltaMs) {
    final float xPos = this.xPos.getValuef();
    final float yPos = this.yPos.getValuef();
    final float pos = this.pos.getValuef();
    final float vortexSize = this.vortexBase.getValuef() + this.vortexSize.getValuef();
    final float xSlope = this.xSlope.getValuef();
    final float ySlope = this.ySlope.getValuef();
    final float zSlope = this.zSlope.getValuef();

    for (Leaf leaf : tree.leaves) {
      float radix = abs((xSlope*abs(leaf.x-model.cx) + ySlope*abs(leaf.y-model.cy) + zSlope*abs(leaf.z-model.cz)) % vortexSize);
      float dist = dist(leaf.x, leaf.y, xPos, yPos); 
      float size = max(20*INCHES, 2*vortexSize - .5*dist);
      float b = 100 - (100 / size) * LXUtils.wrapdistf(radix, pos * vortexSize, vortexSize);
      setColor(leaf, (b > 0) ? LXColor.gray(b) : #000000);
    }
  }
}

public class Rotors extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  private final SawLFO aziumuth = new SawLFO(0, PI, startModulator(
    new SinLFO(11000, 29000, 33000)
    ));

  private final SawLFO aziumuth2 = new SawLFO(PI, 0, startModulator(
    new SinLFO(23000, 49000, 53000)
    ));

  private final SinLFO falloff = new SinLFO(200, 900, startModulator(
    new SinLFO(5000, 17000, 12398)
    ));

  private final SinLFO falloff2 = new SinLFO(250, 800, startModulator(
    new SinLFO(6000, 11000, 19880)
    ));

  public Rotors(LX lx) {
    super(lx);
    startModulator(aziumuth);
    startModulator(aziumuth2);
    startModulator(falloff);
    startModulator(falloff2);
  }

  public void run(double deltaMs) {
    float aziumuth = this.aziumuth.getValuef();
    float aziumuth2 = this.aziumuth2.getValuef();
    float falloff = this.falloff.getValuef();
    float falloff2 = this.falloff2.getValuef();
    for (Leaf leaf : tree.leaves) {
      float yn = (1 - .8 * (leaf.y - model.yMin) / model.yRange);
      float fv = .3 * falloff * yn;
      float fv2 = .3 * falloff2 * yn;
      float b = max(
        100 - fv * LXUtils.wrapdistf(leaf.point.azimuth, aziumuth, PI), 
        100 - fv2 * LXUtils.wrapdistf(leaf.point.azimuth, aziumuth2, PI)
        );
      b = max(30, b);
      float s = constrain(50 + b/2, 0, 100);
      setColor(leaf, palette.getColor(leaf.point, s, b));
    }
  }
}

public class DiamondRain extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  private final static int NUM_DROPS = 24; 

  public DiamondRain(LX lx) {
    super(lx);
    for (int i = 0; i < NUM_DROPS; ++i) {
      addLayer(new Drop(lx));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }

  private class Drop extends LXLayer {

    private final float MAX_LENGTH = 14*FEET;

    private final SawLFO yPos = new SawLFO(model.yMax + MAX_LENGTH, model.yMin - MAX_LENGTH, 4000 + Math.random() * 3000);
    private float azimuth;
    private float azimuthFalloff;
    private float yFalloff;

    Drop(LX lx) {
      super(lx);
      startModulator(yPos.randomBasis());
      init();
    }

    private void init() {
      this.yPos.setPeriod(2500 + Math.random() * 11000);
      azimuth = (float) Math.random() * TWO_PI;
      azimuthFalloff = 140 + 340 * (float) Math.random();
      yFalloff = 100 / (2*FEET + 12*FEET * (float) Math.random());
    }

    public void run(double deltaMs) {
      float yPos = this.yPos.getValuef();
      if (this.yPos.loop()) {
        init();
      }
      for (Leaf leaf : tree.leaves) {
        float yDist = abs(leaf.y - yPos);
        float azimuthDist = abs(leaf.point.azimuth - azimuth); 
        float b = 100 - yFalloff*yDist - azimuthFalloff*azimuthDist;
        if (b > 0) {
          addColor(leaf, palette.getColor(leaf.point, b));
        }
      }
    }
  }
}

public class Azimuth extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter azim = new CompoundParameter("Azimuth", 0, TWO_PI);  

  public Azimuth(LX lx) {
    super(lx);
    addParameter("azim", this.azim);
  }

  public void run(double deltaMs) {
    float azim = this.azim.getValuef();
    for (Branch b : tree.branches) {
      setColor(b, LX.hsb(0, 0, max(0, 100 - 400 * LXUtils.wrapdistf(b.azimuth, azim, TWO_PI))));
    }
  }
}

public class AxisTest extends LXPattern {
 
  public final CompoundParameter xPos = new CompoundParameter("X", 0);
  public final CompoundParameter yPos = new CompoundParameter("Y", 0);
  public final CompoundParameter zPos = new CompoundParameter("Z", 0);

  public AxisTest(LX lx) {
    super(lx);
    addParameter("xPos", xPos);
    addParameter("yPos", yPos);
    addParameter("zPos", zPos);
  }

  public void run(double deltaMs) {
    float x = this.xPos.getValuef();
    float y = this.yPos.getValuef();
    float z = this.zPos.getValuef();
    for (LXPoint p : model.points) {
      float d = abs(p.xn - x);
      d = min(d, abs(p.yn - y));
      d = min(d, abs(p.zn - z));
      colors[p.index] = palette.getColor(p, max(0, 100 - 1000*d));
    }
  }
}

public class Swarm extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  private static final int NUM_GROUPS = 5;

  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 2000, 10000, 500)
    .setDescription("Speed of swarm motion")
    .setExponent(.25);
    
  public final CompoundParameter base =
    new CompoundParameter("Base", 10, 60, 1)
    .setDescription("Base size of swarm");
    
  public final CompoundParameter floor =
    new CompoundParameter("Floor", 20, 0, 100)
    .setDescription("Base level of swarm brightness");

  public final LXModulator[] pos = new LXModulator[NUM_GROUPS];

  public final LXModulator swarmX = startModulator(new SinLFO(
    startModulator(new SinLFO(0, .2, startModulator(new SinLFO(3000, 9000, 17000).randomBasis()))), 
    startModulator(new SinLFO(.8, 1, startModulator(new SinLFO(4000, 7000, 15000).randomBasis()))), 
    startModulator(new SinLFO(9000, 17000, 33000).randomBasis())
    ).randomBasis());

  public final LXModulator swarmY = startModulator(new SinLFO(
    startModulator(new SinLFO(0, .2, startModulator(new SinLFO(3000, 9000, 19000).randomBasis()))), 
    startModulator(new SinLFO(.8, 1, startModulator(new SinLFO(4000, 7000, 13000).randomBasis()))), 
    startModulator(new SinLFO(9000, 17000, 33000).randomBasis())
    ).randomBasis());

  public final LXModulator swarmZ = startModulator(new SinLFO(
    startModulator(new SinLFO(0, .2, startModulator(new SinLFO(3000, 9000, 19000).randomBasis()))), 
    startModulator(new SinLFO(.8, 1, startModulator(new SinLFO(4000, 7000, 13000).randomBasis()))), 
    startModulator(new SinLFO(9000, 17000, 33000).randomBasis())
    ).randomBasis());

  public Swarm(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("base", this.base);
    addParameter("floor", this.floor);
    for (int i = 0; i < pos.length; ++i) {
      final int ii = i;
      float start = (i % 2 == 0) ? 0 : LeafAssemblage.NUM_LEAVES;
      pos[i] = new SawLFO(start, LeafAssemblage.NUM_LEAVES - start, new FunctionalParameter() {
        public double getValue() {
          return speed.getValue() + ii*500;
        }
      }).randomBasis();
      startModulator(pos[i]);
    }
  }

  public void run(double deltaMs) {
    float base = this.base.getValuef();
    float swarmX = this.swarmX.getValuef();
    float swarmY = this.swarmY.getValuef();
    float swarmZ = this.swarmZ.getValuef();
    float floor = this.floor.getValuef();

    int i = 0;
    for (LeafAssemblage assemblage : tree.assemblages) {
      float pos = this.pos[i++ % NUM_GROUPS].getValuef();
      for (Leaf leaf : assemblage.leaves) {
        float falloff = min(100, base + 40 * dist(leaf.point.xn, leaf.point.yn, leaf.point.zn, swarmX, swarmY, swarmZ));
        float b = max(floor, 100 - falloff * LXUtils.wrapdistf(leaf.orientation.index, pos, LeafAssemblage.LEAVES.length));
        setColor(leaf, LXColor.gray(b));
      }
    }
  }
}

public class Sizzle extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  private static final int NUM_WAVES = 13;
  private static final int NUM_SIZES = 19;

  public LXModulator[] wave = new LXModulator[NUM_WAVES];
  public LXModulator[] size = new LXModulator[NUM_SIZES];

  public int[][][] precompute = new int[NUM_WAVES][NUM_SIZES][Leaf.NUM_LEDS];

  public final CompoundParameter base =
    new CompoundParameter("Base", 3, 1, Leaf.NUM_LEDS)
    .setDescription("Base size of the leaf sizzle");
    
  public final CompoundParameter max =
    new CompoundParameter("Max", Leaf.NUM_LEDS, 1, Leaf.NUM_LEDS)
    .setDescription("Max size of the leaf sizzle");    

  public Sizzle(LX lx) {
    super(lx);
    addParameter("base", this.base);
    addParameter("max", this.max);
    for (int i = 0; i < wave.length; ++i) {
      int start = (i % 2 == 0) ? 0 : Leaf.NUM_LEDS;
      this.wave[i] = startModulator(new SawLFO(start, Leaf.NUM_LEDS-start, 1000*i).randomBasis());
    }
    for (int i = 0; i < size.length; ++i) {
      this.size[i] = startModulator(new SinLFO(this.base, max, 7000 + 1000*i).randomBasis());
    }
  }

  public void run(double deltaMs) {
    for (int w = 0; w < NUM_WAVES; ++w) {
      float wave = this.wave[w].getValuef();
      for (int s = 0; s < NUM_SIZES; ++s) {
        float falloff = 100 / this.size[s].getValuef();
        for (int p = 0; p < Leaf.NUM_LEDS; ++p) {
          this.precompute[w][s][p] = LXColor.gray(max(0, 100 - falloff * LXUtils.wrapdistf(p, wave, Leaf.NUM_LEDS)));
        }
      }
    }
    
    int li = 0;
    for (Leaf leaf : tree.leaves) {
      int wi = li % NUM_WAVES;
      int si = li % NUM_SIZES;
      for (int i = 0; i < Leaf.NUM_LEDS; ++i) {
        colors[leaf.point.index + i] = this.precompute[wi][si][i];
      }
      ++li;
    }
  }
}

public class sphericalWave extends LXPattern {
  // by  Aimone
  hist inputHist;

  public final CompoundParameter input =
    new CompoundParameter("input", 0, 1)
    .setDescription("Input (0-1)");
    
  public final CompoundParameter yPos =
    new CompoundParameter("yPos", model.cy, model.yMin, model.yMax)
    .setDescription("Controls Y");

  public final CompoundParameter xPos =
    new CompoundParameter("xPos", model.cx, model.xMin, model.xMax)
    .setDescription("Controls X");

  public final CompoundParameter zPos =
    new CompoundParameter("zPos", model.cz, model.zMin, model.zMax)
    .setDescription("Controls Z");

  public final CompoundParameter waveSpeed =
    new CompoundParameter("speed", 0.001, 0.5)
    .setDescription("Controls the speed");

  public final CompoundParameter falloff =
    new CompoundParameter("falloff", 0, 40*FEET)
    .setDescription("Controls the falloff over distance");
    
   public final CompoundParameter scale =
    new CompoundParameter("scale", 0.1, 20)
    .setDescription("Scale the input (after offset)");
   
   public final CompoundParameter offset =
    new CompoundParameter("offset", 0, 2)
    .setDescription("Offset the input (-1, 1)");
    
   public final CompoundParameter sourceColor =
    new CompoundParameter("Color", 0, 360)
    .setDescription("Controls the falloff");
   
   public final DiscreteParameter clamp =
    new DiscreteParameter("clamp", 0, 2 )
    .setDescription("clamp the input signal to be positive ");
  
  public sphericalWave(LX lx) {
     super(lx);
     addParameter(input);
     addParameter(yPos);
     addParameter(xPos);
     addParameter(zPos);
     addParameter(waveSpeed);
     addParameter(falloff);
     addParameter(offset);
     addParameter(scale);
     addParameter(sourceColor);
     addParameter(clamp);
     inputHist = new hist(1000);
  }
  
  public void run(double deltaMs) {
    float inputVal = (float)input.getValue();
    inputHist.addValue(inputVal);
    
    float speed = (float)waveSpeed.getValue();
    color leafColor = LX.rgb(0, 0,0);    
    
//    println("input val is "+inputVal);
    float offsetVal = (float)offset.getValue();
    offsetVal = offsetVal-1;
    
    float scaleVal = (float)scale.getValue();
    float dist=0;
    float sourceAdd = 0;
    int histIdx=0;
    float histVal=0;
    float sourceBaseColor = (float)sourceColor.getValue();
    float clampInput = (int)clamp.getValue();
    
    for (Leaf leaf : tree.leaves) {
       dist = sqrt(sq((float)leaf.x - (float)xPos.getValue()) 
        + sq((float)leaf.y - (float)yPos.getValue())
        + sq((float)leaf.z - (float)zPos.getValue()));
       sourceAdd = 0;
       histIdx = inputHist.lookupInd((int)(dist*speed));
       
       if (histIdx != -1){
          if (clampInput == 0){
            histVal= min(1,inputHist.getValue(histIdx)+offsetVal)*scaleVal*max(0, 100-min(1, dist/(float)falloff.getValue())*100 );
          }else{
            histVal= min(1,max(0,inputHist.getValue(histIdx)+offsetVal)*scaleVal)*max(0, 100-min(1, dist/(float)falloff.getValue())*100 );
          }
          leafColor = LX.hsb(sourceBaseColor, 100, histVal);
       }
       setColor(leaf, leafColor);
    
    }  
  }
}