public static class Wave extends LXPattern {
  // by Mark C. Slee
  
  public final CompoundParameter size =
    new CompoundParameter("Size", 4*FEET, 28*FEET)
    .setDescription("Width of the wave");
    
  public final CompoundParameter rate =
    new CompoundParameter("Rate", 6000, 18000)
    .setDescription("Rate of the of the wave motion");
  
  private final SawLFO phase = new SawLFO(0, TWO_PI, rate);
  
  private final double[] bins = new double[512];
  
  public Wave(LX lx) {
    super(lx);
    startModulator(phase);
    addParameter(size);
    addParameter(rate);
  }
    
  public void run(double deltaMs) {
    double phaseValue = phase.getValue();
    float falloff = 100 / size.getValuef();
    for (int i = 0; i < bins.length; ++i) {
      bins[i] = model.cy + model.yRange/2 * Math.sin(i * TWO_PI / bins.length + phaseValue);
      println(bins[i] + "-"+i);
    }
    for (LXPoint p : model.points) {
      int idx = Math.round((bins.length-1) * (p.x - model.xMin) / model.xRange);
      float y1 = (float) bins[idx];
      float y2 = (float) bins[(idx*4 / 3 + bins.length/2) % bins.length];
      float b1 = max(0, 100 - falloff * abs(p.y - y1));
      float b2 = max(0, 100 - falloff * abs(p.y - y2));
      float b = max(b1, b2);
      colors[p.index] = b > 0 ? palette.getColor(p, b) : #000000;
    }
  }
}

public static class Swirl extends LXPattern {
  // by Mark C. Slee
  
  private final SinLFO xPos = new SinLFO(model.xMin, model.xMax, startModulator(
    new SinLFO(19000, 39000, 51000).randomBasis()
  ));
    
  private final SinLFO yPos = new SinLFO(model.yMin, model.yMax, startModulator(
    new SinLFO(19000, 39000, 57000).randomBasis()
  ));
  
  public final CompoundParameter swarmBase = new CompoundParameter("Base",
    12*INCHES,
    1*INCHES,
    140*INCHES
  );
  
  public final CompoundParameter swarmMod = new CompoundParameter("Mod", 0, 120*INCHES);
  
  private final SinLFO swarmSize = new SinLFO(0, swarmMod, 19000);
  
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
  
  public Swirl(LX lx) {
    super(lx);
    addParameter(swarmBase);
    addParameter(swarmMod);
    startModulator(xPos.randomBasis());
    startModulator(yPos.randomBasis());
    startModulator(pos);
    startModulator(swarmSize);
    startModulator(xSlope);
    startModulator(ySlope);
    startModulator(zSlope);
  }
  
  public void run(double deltaMs) {
    final float xPos = this.xPos.getValuef();
    final float yPos = this.yPos.getValuef();
    final float pos = this.pos.getValuef();
    final float swarmSize = this.swarmBase.getValuef() + this.swarmSize.getValuef();
    final float xSlope = this.xSlope.getValuef();
    final float ySlope = this.ySlope.getValuef();
    final float zSlope = this.zSlope.getValuef();
    
    for (LXPoint p : model.points) {
      float radix = (xSlope*(p.x-model.cx) + ySlope*(p.y-model.cy) + zSlope*(p.z-model.cz)) % swarmSize; // (p.x - model.xMin + p.y - model.yMin) % swarmSize;
      float dist = dist(p.x, p.y, xPos, yPos); 
      float size = max(20*INCHES, 2*swarmSize - .5*dist);
      float b = 100 - (100 / size) * LXUtils.wrapdistf(radix, pos * swarmSize, swarmSize);
      colors[p.index] = (b > 0) ? palette.getColor(p, b) : #000000;
    }
  }
}

public static class Rotors extends LXPattern {
  // by Mark C. Slee
  
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
    for (LXPoint p : model.points) {
      float yn = (1 - .8 * (p.y - model.yMin) / model.yRange);
      float fv = .3 * falloff * yn;
      float fv2 = .3 * falloff2 * yn;
      float b = max(
        100 - fv * LXUtils.wrapdistf(p.azimuth, aziumuth, PI),
        100 - fv2 * LXUtils.wrapdistf(p.azimuth, aziumuth2, PI)
      );
      b = max(30, b);
      float s = constrain(50 + b/2, 0, 100);
      colors[p.index] = palette.getColor(p, s, b);
      
    }
  }
}

public static class DiamondRain extends LXPattern {
  // by Mark C. Slee
 
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
      for (LXPoint p : model.points) {
        float yDist = abs(p.y - yPos);
        float azimuthDist = abs(p.azimuth - azimuth); 
        float b = 100 - yFalloff*yDist - azimuthFalloff*azimuthDist;
        if (b > 0) {
          addColor(p.index, palette.getColor(p, b));
        }
      }
    }
  }  
}

public class Azimuth extends LXPattern {
  
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

public class Swarm extends LXPattern {
  
  private static final int NUM_GROUPS = 5;
  
  public final CompoundParameter speed = new CompoundParameter("Speed", 2000, 10000, 500);
  public final CompoundParameter base = new CompoundParameter("Base", 10, 60, 1);
  
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
  
  public Swarm(LX lx) {
    super(lx);
    addParameter("speed", speed);
    addParameter("base", base);
    for (int i = 0; i < pos.length; ++i) {
      final int ii = i;
      pos[i] = new SawLFO(0, LeafAssemblage.NUM_LEAVES, new FunctionalParameter() {
        public double getValue() {
          return speed.getValue() + ii*500; 
      }}).randomBasis();
      startModulator(pos[i]);
    }
  }
  
  public void run(double deltaMs) {
    int i = 0;
    float base = this.base.getValuef();
    float swarmX = this.swarmX.getValuef();
    float swarmY = this.swarmY.getValuef();
    for (LeafAssemblage assemblage : tree.assemblages) {
      float pos = this.pos[i++ % NUM_GROUPS].getValuef();
      for (Leaf leaf : assemblage.leaves) {
        float falloff = min(100, base + 40 * dist(leaf.point.xn, leaf.point.yn, swarmX, swarmY));  
        colors[leaf.point.index] = palette.getColor(leaf.point, max(20, 100 - falloff*LXUtils.wrapdistf(leaf.orientation.index, pos, LeafAssemblage.LEAVES.length)));
      }
    }
  }
}