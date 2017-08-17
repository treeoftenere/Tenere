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

public class PatternSolid extends LXPattern {
  
  public final CompoundParameter h = new CompoundParameter("Hue", 0, 360);
  public final CompoundParameter s = new CompoundParameter("Sat", 0, 100);
  public final CompoundParameter b = new CompoundParameter("Brt", 100, 100);
  
  public PatternSolid(LX lx) {
    super(lx);
    addParameter("h", this.h);
    addParameter("s", this.s);
    addParameter("b", this.b);
  }
  
  public void run(double deltaMs) {
    setColors(LXColor.hsb(this.h.getValue(), this.s.getValue(), this.b.getValue()));
  }
}

public class PatternTumbler extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  private LXModulator azimuthRotation = startModulator(new SawLFO(0, 1, 15000).randomBasis());
  private LXModulator thetaRotation = startModulator(new SawLFO(0, 1, 13000).randomBasis());
  
  public PatternTumbler(LX lx) {
    super(lx);
  }
    
  public void run(double deltaMs) {
    float azimuthRotation = this.azimuthRotation.getValuef();
    float thetaRotation = this.thetaRotation.getValuef();
    for (Leaf leaf : model.leaves) {
      float tri1 = LXUtils.trif(azimuthRotation + leaf.point.azimuth / PI);
      float tri2 = LXUtils.trif(thetaRotation + (PI + leaf.point.theta) / PI);
      float tri = max(tri1, tri2);
      setColor(leaf, LXColor.gray(100 * tri * tri));
    }
  }
}

public class PatternBorealis extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed =
    new CompoundParameter("Speed", .5, .01, 1)
    .setDescription("Speed of motion");
  
  public final CompoundParameter scale =
    new CompoundParameter("Scale", .5, .1, 1)
    .setDescription("Scale of lights");
  
  public final CompoundParameter spread =
    new CompoundParameter("Spread", 6, .1, 10)
    .setDescription("Spreading of the motion");
  
  public final CompoundParameter base =
    new CompoundParameter("Base", .5, .2, 1)
    .setDescription("Base brightness level");
    
  public final CompoundParameter contrast =
    new CompoundParameter("Contrast", 1, .5, 2)
    .setDescription("Contrast of the lights");    
  
  public PatternBorealis(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("scale", this.scale);
    addParameter("spread", this.spread);
    addParameter("base", this.base);
    addParameter("contrast", this.contrast);
  }
  
  private float yBasis = 0;
  
  public void run(double deltaMs) {
    this.yBasis -= deltaMs * .0005 * this.speed.getValuef();
    float scale = this.scale.getValuef();
    float spread = this.spread.getValuef();
    float base = .01 * this.base.getValuef();
    float contrast = this.contrast.getValuef();
    for (Leaf leaf : tree.leaves) {
      float nv = noise(
        scale * (base * leaf.point.rxz - spread * leaf.point.yn),
        leaf.point.yn + this.yBasis
      );
      setColor(leaf, LXColor.gray(constrain(contrast * (-50 + 180 * nv), 0, 100)));
    }
  }
}

public class PatternClouds extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter thickness =
    new CompoundParameter("Thickness", 50, 100, 0)
    .setDescription("Thickness of the cloud formation");
  
  public final CompoundParameter xSpeed = (CompoundParameter)
    new CompoundParameter("XSpd", 0, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Motion along the X axis");

  public final CompoundParameter ySpeed = (CompoundParameter)
    new CompoundParameter("YSpd", 0, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Motion along the Y axis");
    
  public final CompoundParameter zSpeed = (CompoundParameter)
    new CompoundParameter("ZSpd", 0, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
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
    
  public PatternClouds(LX lx) {
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

public class PatternScanner extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", .5, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
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
  
  public PatternScanner(LX lx) {
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

public class PatternStarlight extends TenerePattern {
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
  
  public final CompoundParameter numStars = (CompoundParameter)
    new CompoundParameter("Num", 5000, 50, MAX_STARS)
    .setExponent(2)
    .setDescription("Number of stars");
  
  private final Star[] stars = new Star[MAX_STARS];
    
  private final ArrayList<Leaf> shuffledLeaves;
    
  public PatternStarlight(LX lx) {
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
      int maxLeaves = shuffledLeaves.size();
      for (int i = 0; i < LEAVES_PER_STAR; ++i) {
        int leafIndex = num * LEAVES_PER_STAR + i;
        if (leafIndex < maxLeaves) {
          setColor(shuffledLeaves.get(leafIndex), c);
        }
      }
      this.accum += deltaMs;
      if (this.accum > this.period) {
        this.active = false;
      }
    }
  }

}

public class PatternWaves extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  final int NUM_LAYERS = 3;
  
  final float AMP_DAMPING_V = 1.5;
  final float AMP_DAMPING_A = 2.5;
  
  final float LEN_DAMPING_V = 1.5;
  final float LEN_DAMPING_A = 1.5;

  public final CompoundParameter rate = (CompoundParameter)
    new CompoundParameter("Rate", 6000, 48000, 2000)
    .setDescription("Rate of the of the wave motion")
    .setExponent(.3);

  public final CompoundParameter size =
    new CompoundParameter("Size", 4*FEET, 6*INCHES, 28*FEET)
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
    
  private final LXModulator amp1Damp = startModulator(new DampedParameter(this.amp1, AMP_DAMPING_V, AMP_DAMPING_A));
  private final LXModulator amp2Damp = startModulator(new DampedParameter(this.amp2, AMP_DAMPING_V, AMP_DAMPING_A));
  private final LXModulator amp3Damp = startModulator(new DampedParameter(this.amp3, AMP_DAMPING_V, AMP_DAMPING_A));
  
  private final LXModulator len1Damp = startModulator(new DampedParameter(this.len1, LEN_DAMPING_V, LEN_DAMPING_A));
  private final LXModulator len2Damp = startModulator(new DampedParameter(this.len2, LEN_DAMPING_V, LEN_DAMPING_A));
  private final LXModulator len3Damp = startModulator(new DampedParameter(this.len3, LEN_DAMPING_V, LEN_DAMPING_A));  

  private final LXModulator sizeDamp = startModulator(new DampedParameter(this.size, 40*FEET, 80*FEET));

  private final double[] bins = new double[512];

  public PatternWaves(LX lx) {
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
    float amp1 = this.amp1Damp.getValuef();
    float amp2 = this.amp2Damp.getValuef();
    float amp3 = this.amp3Damp.getValuef();
    float len1 = this.len1Damp.getValuef();
    float len2 = this.len2Damp.getValuef();
    float len3 = this.len3Damp.getValuef();    
    float falloff = 100 / this.sizeDamp.getValuef();
    
    for (int i = 0; i < bins.length; ++i) {
      bins[i] = model.cy + model.yRange/2 * Math.sin(i * TWO_PI / bins.length + phaseValue);
    }
    for (Leaf leaf : tree.leaves) {
      int idx = Math.round((bins.length-1) * (len1 * leaf.point.xn)) % bins.length;
      int idx2 = Math.round((bins.length-1) * (len2 * (.2 + leaf.point.xn))) % bins.length;
      int idx3 = Math.round((bins.length-1) * (len3 * (1.7 - leaf.point.xn))) % bins.length; 
      
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

public class PatternVortex extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 2000, 9000, 300)
    .setExponent(.5)
    .setDescription("Speed of vortex motion");
  
  public final CompoundParameter size =
    new CompoundParameter("Size",  4*FEET, 1*FEET, 10*FEET)
    .setDescription("Size of vortex");
  
  public final CompoundParameter xPos = (CompoundParameter)
    new CompoundParameter("XPos", model.cx, model.xMin, model.xMax)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("X-position of vortex center");
    
  public final CompoundParameter yPos = (CompoundParameter)
    new CompoundParameter("YPos", model.cy, model.yMin, model.yMax)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Y-position of vortex center");
    
  public final CompoundParameter xSlope = (CompoundParameter)
    new CompoundParameter("XSlp", .2, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("X-slope of vortex center");
    
  public final CompoundParameter ySlope = (CompoundParameter)
    new CompoundParameter("YSlp", .5, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Y-slope of vortex center");
    
  public final CompoundParameter zSlope = (CompoundParameter)
    new CompoundParameter("ZSlp", .3, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Z-slope of vortex center");
  
  private final LXModulator pos = startModulator(new SawLFO(1, 0, this.speed));
  
  private final LXModulator sizeDamped = startModulator(new DampedParameter(this.size, 5*FEET, 8*FEET));
  private final LXModulator xPosDamped = startModulator(new DampedParameter(this.xPos, model.xRange, 3*model.xRange));
  private final LXModulator yPosDamped = startModulator(new DampedParameter(this.yPos, model.yRange, 3*model.yRange));
  private final LXModulator xSlopeDamped = startModulator(new DampedParameter(this.xSlope, 3, 6));
  private final LXModulator ySlopeDamped = startModulator(new DampedParameter(this.ySlope, 3, 6));
  private final LXModulator zSlopeDamped = startModulator(new DampedParameter(this.zSlope, 3, 6));

  public PatternVortex(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("size", this.size);
    addParameter("xPos", this.xPos);
    addParameter("yPos", this.yPos);
    addParameter("xSlope", this.xSlope);
    addParameter("ySlope", this.ySlope);
    addParameter("zSlope", this.zSlope);
  }

  public void run(double deltaMs) {
    final float xPos = this.xPosDamped.getValuef();
    final float yPos = this.yPosDamped.getValuef();
    final float size = this.sizeDamped.getValuef();
    final float pos = this.pos.getValuef();
    
    final float xSlope = this.xSlopeDamped.getValuef();
    final float ySlope = this.ySlopeDamped.getValuef();
    final float zSlope = this.zSlopeDamped.getValuef();

    float dMult = 2 / size;
    for (Leaf leaf : tree.leaves) {
      float radix = abs((xSlope*abs(leaf.x-model.cx) + ySlope*abs(leaf.y-model.cy) + zSlope*abs(leaf.z-model.cz)));
      float dist = dist(leaf.x, leaf.y, xPos, yPos); 
      //float falloff = 100 / max(20*INCHES, 2*size - .5*dist);
      //float b = 100 - falloff * LXUtils.wrapdistf(radix, pos * size, size);
      float b = abs(((dist + radix + pos * size) % size) * dMult - 1);
      setColor(leaf, (b > 0) ? LXColor.gray(b*b*100) : #000000);
    }
  }
}

public class PatternAxisPlanes extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter xSpeed = new CompoundParameter("XSpd", 11000, 21000, 5000).setDescription("Speed of motion on X-axis");
  public final CompoundParameter ySpeed = new CompoundParameter("YSpd", 13000, 21000, 5000).setDescription("Speed of motion on Y-axis");
  public final CompoundParameter zSpeed = new CompoundParameter("ZSpd", 17000, 21000, 5000).setDescription("Speed of motion on Z-axis");
  
  public final CompoundParameter xSize = new CompoundParameter("XSize", .1, .05, .3).setDescription("Size of X scanner");
  public final CompoundParameter ySize = new CompoundParameter("YSize", .1, .05, .3).setDescription("Size of Y scanner");
  public final CompoundParameter zSize = new CompoundParameter("ZSize", .1, .05, .3).setDescription("Size of Z scanner");
  
  private final LXModulator xPos = startModulator(new SinLFO(0, 1, this.xSpeed).randomBasis());
  private final LXModulator yPos = startModulator(new SinLFO(0, 1, this.ySpeed).randomBasis());
  private final LXModulator zPos = startModulator(new SinLFO(0, 1, this.zSpeed).randomBasis());
  
  public PatternAxisPlanes(LX lx) {
    super(lx);
    addParameter("xSpeed", this.xSpeed);
    addParameter("ySpeed", this.ySpeed);
    addParameter("zSpeed", this.zSpeed);
    addParameter("xSize", this.xSize);
    addParameter("ySize", this.ySize);
    addParameter("zSize", this.zSize);
  }
  
  public void run(double deltaMs) {
    float xPos = this.xPos.getValuef();
    float yPos = this.yPos.getValuef();
    float zPos = this.zPos.getValuef();
    float xFalloff = 100 / this.xSize.getValuef();
    float yFalloff = 100 / this.ySize.getValuef();
    float zFalloff = 100 / this.zSize.getValuef();
    
    for (Leaf leaf : model.leaves) {
      float b = max(max(
        100 - xFalloff * abs(leaf.point.xn - xPos),
        100 - yFalloff * abs(leaf.point.yn - yPos)),
        100 - zFalloff * abs(leaf.point.zn - zPos)
      );
      setColor(leaf, LXColor.gray(max(0, b)));
    }
  }
}

public class PatternAudioMeter extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter mode =
    new CompoundParameter("Mode", 0)
    .setDescription("Sets the mode of the equalizer");
    
  public final CompoundParameter size =
    new CompoundParameter("Size", .2, .1, .4)
    .setDescription("Sets the size of the display");
  
  public PatternAudioMeter(LX lx) {
    super(lx);
    addParameter("mode", this.mode);
    addParameter("size", this.size);
  }
  
  public void run(double deltaMs) {
    float meter = lx.engine.audio.meter.getValuef();
    float mode = this.mode.getValuef();
    float falloff = 100 / this.size.getValuef();
    for (Leaf leaf : model.leaves) {
      float leafPos = 2 * abs(leaf.point.yn - .5);
      float b1 = constrain(50 - falloff * (leafPos - meter), 0, 100);
      float b2 = constrain(50 - falloff * abs(leafPos - meter), 0, 100);
      setColor(leaf, LXColor.gray(lerp(b1, b2, mode)));
    }
  } 
}

public abstract class BufferPattern extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speedRaw =
    new CompoundParameter("Speed", 256, 1024, 64)
    .setDescription("Speed of the audio waves");
  
  public final LXModulator speed = startModulator(new DampedParameter(speedRaw, 256, 512));
  
  private static final int BUFFER_SIZE = 2048;
  protected int[] history = new int[BUFFER_SIZE];
  protected int cursor = 0;

  public BufferPattern(LX lx) {
    super(lx);
    addParameter("speed", this.speedRaw);
    for (int i = 0; i < this.history.length; ++i) {
      this.history[i] = #000000;
    }
  }
  
  public final void run(double deltaMs) {
    // Add to history
    if (--this.cursor < 0) {
      this.cursor = this.history.length - 1;
    }
    this.history[this.cursor] = getColor();
    onRun(deltaMs);
  }
  
  protected int getColor() {
    return LXColor.gray(100 * getLevel());
  }
  
  protected float getLevel() {
    return 0;
  }
  
  abstract void onRun(double deltaMs); 
}

public abstract class WavePattern extends BufferPattern {
  
  public static final int NUM_MODES = 5; 
  private final float[] dm = new float[NUM_MODES];
  
  public final CompoundParameter mode =
    new CompoundParameter("Mode", 0, NUM_MODES - 1)
    .setDescription("Mode of the wave motion");
  
  private final LXModulator modeDamped = startModulator(new DampedParameter(this.mode, 1, 8)); 
  
  protected WavePattern(LX lx) {
    super(lx);
    addParameter("mode", this.mode);
  }
    
  public void onRun(double deltaMs) {
    float speed = this.speed.getValuef();
    float mode = this.modeDamped.getValuef();
    float lerp = mode % 1;
    int floor = (int) (mode - lerp);
    for (Leaf leaf : model.leaves) {
      dm[0] = abs(leaf.point.yn - .5);
      dm[1] = .5 * abs(leaf.point.xn - .5) + .5 * abs(leaf.point.yn - .5);
      dm[2] = abs(leaf.point.xn - .5);
      dm[3] = leaf.point.yn;
      dm[4] = 1 - leaf.point.yn;
      
      int offset1 = round(dm[floor] * dm[floor] * speed);
      int offset2 = round(dm[(floor + 1) % dm.length] * dm[(floor + 1) % dm.length] * speed);
      int c1 = this.history[(this.cursor + offset1) % this.history.length];
      int c2 = this.history[(this.cursor + offset2) % this.history.length];
      setColor(leaf, LXColor.lerp(c1, c2, lerp));
    }
  }
  
}

public class PatternAudioWaves extends WavePattern {
        
  public final BooleanParameter manual =
    new BooleanParameter("Manual", false)
    .setDescription("When true, uses the manual parameter");
    
  public final CompoundParameter level =
    new CompoundParameter("Level", 0)
    .setDescription("Manual input level");
    
  public PatternAudioWaves(LX lx) {
    super(lx);
    addParameter("manual", this.manual);
    addParameter("level", this.level);
  }
  
  protected float getLevel() {
    return this.manual.isOn() ? this.level.getValuef() : this.lx.engine.audio.meter.getValuef();
  }
  
} 

public class PatternSirens extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter base =
    new CompoundParameter("Base", 20, 0, 60)
    .setDescription("Base brightness level");
  
  public final CompoundParameter speed1 = new CompoundParameter("Spd1", 9000, 19000, 5000).setDescription("Speed of siren 1");
  public final CompoundParameter speed2 = new CompoundParameter("Spd2", 9000, 19000, 5000).setDescription("Speed of siren 2");
  public final CompoundParameter speed3 = new CompoundParameter("Spd3", 9000, 19000, 5000).setDescription("Speed of siren 3");
  public final CompoundParameter speed4 = new CompoundParameter("Spd4", 9000, 19000, 5000).setDescription("Speed of siren 4");
  
  public final CompoundParameter size1 = new CompoundParameter("Sz1", PI / 8, PI / 32, HALF_PI).setDescription("Size of siren 1");
  public final CompoundParameter size2 = new CompoundParameter("Sz2", PI / 8, PI / 32, HALF_PI).setDescription("Size of siren 2");
  public final CompoundParameter size3 = new CompoundParameter("Sz3", PI / 8, PI / 32, HALF_PI).setDescription("Size of siren 3");
  public final CompoundParameter size4 = new CompoundParameter("Sz4", PI / 8, PI / 32, HALF_PI).setDescription("Size of siren 4");
  
  public final LXModulator azim1 = startModulator(new SawLFO(0, TWO_PI, this.speed1).randomBasis());
  public final LXModulator azim2 = startModulator(new SawLFO(TWO_PI, 0, this.speed2).randomBasis());
  public final LXModulator azim3 = startModulator(new SawLFO(0, TWO_PI, this.speed3).randomBasis());
  public final LXModulator azim4 = startModulator(new SawLFO(TWO_PI, 0, this.speed2).randomBasis());
  
  public PatternSirens(LX lx) {
    super(lx);
    addParameter("speed1", this.speed1);
    addParameter("speed2", this.speed2);
    addParameter("speed3", this.speed3);
    addParameter("speed4", this.speed4);
    addParameter("size1", this.size1);
    addParameter("size2", this.size2);
    addParameter("size3", this.size3);
    addParameter("size4", this.size4);
  }
  
  public void run(double deltaMs) {
    float azim1 = this.azim1.getValuef();
    float azim2 = this.azim2.getValuef();
    float azim3 = this.azim3.getValuef();
    float azim4 = this.azim3.getValuef();
    float falloff1 = 100 / this.size1.getValuef();
    float falloff2 = 100 / this.size2.getValuef();
    float falloff3 = 100 / this.size3.getValuef();
    float falloff4 = 100 / this.size4.getValuef();
    for (Leaf leaf : model.leaves) {
      float azim = leaf.point.azimuth;
      float dist = max(max(max(
        100 - falloff1 * LXUtils.wrapdistf(azim, azim1, TWO_PI),
        100 - falloff2 * LXUtils.wrapdistf(azim, azim2, TWO_PI)),
        100 - falloff3 * LXUtils.wrapdistf(azim, azim3, TWO_PI)),
        100 - falloff4 * LXUtils.wrapdistf(azim, azim4, TWO_PI)
      );
      setColor(leaf, LXColor.gray(max(0, dist)));
    }
  }
}

public class PatternSlideshow extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  private final String[] PATHS = {
    "main_1200.jpg",
    "The Great Heads-X2proc.jpg"
  };
  
  private final PImage[] images;
  
  private final SawLFO imageIndex;
  
  public final CompoundParameter rate = new CompoundParameter("Rate", 3000, 6000, 500);
  
  public PatternSlideshow(LX lx) {
    super(lx);
    this.images = new PImage[PATHS.length];
    for (int i = 0; i < this.images.length; ++i) {
      this.images[i] = loadImage(PATHS[i]);
      this.images[i].loadPixels();
    }
    addParameter("rate", this.rate);
    this.imageIndex = new SawLFO(0, this.images.length, rate);
    startModulator(this.imageIndex);
  }
  
  public void run(double deltaMs) {
    float imageIndex = this.imageIndex.getValuef();
    int imageFloor = (int) Math.floor(imageIndex); 
    PImage image1 = this.images[imageFloor % this.images.length];
    PImage image2 = this.images[(imageFloor + 1) % this.images.length];
    float imageLerp = imageIndex - imageFloor;
    
    for (Leaf leaf : model.leaves) {
      int c1 = image1.get(
        (int) (leaf.point.xn * (image1.width-1)),
        (int) ((1-leaf.point.yn) * (image1.height-1))
      );
      int c2 = image2.get(
        (int) (leaf.point.xn * (image2.width-1)),
        (int) ((1-leaf.point.yn) * (image2.height-1))
      );
      setColor(leaf, LXColor.lerp(c1, c2, imageLerp));
    }
  }
}

public class PatternSwarm extends TenerePattern {
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

  public PatternSwarm(LX lx) {
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

public abstract class ThreadedPattern extends TenerePattern {
    
  private static final int DEFAULT_NUM_THREADS = 8;
  
  private double deltaMs;  
  private final WorkerThread[] threads; 
  
  public ThreadedPattern(LX lx) {
    super(lx);
    
    // Create threads
    int numThreads = getNumThreads();
    this.threads = new WorkerThread[numThreads];
    for (int i = 0; i < numThreads; ++i) {
      this.threads[i] = new WorkerThread(getClass().getName() + "-Thread" + i);
    }
    
    // Distribute branches over the threads
    allocateBranches();
    
    // Start the threads
    for (WorkerThread thread : this.threads) {
      thread.start();
    }
  }
  
  // Override this if you want a different number of worker threads
  public int getNumThreads() {
    return DEFAULT_NUM_THREADS;
  }
  
  // Your subclass may want to override this method to allocate
  // branches in a different manner
  public void allocateBranches() {
    int i = 0;
    for (Branch branch : model.branches) {
      this.threads[i % this.threads.length].branches.add(branch);
      ++i;
    }
  }
    
  public void run(double deltaMs) {
    // Store frame's deltaMs for threads
    this.deltaMs = deltaMs;
    
    // Notify every thread that it has work to do
    for (WorkerThread thread : this.threads) {
      synchronized (thread) {
        thread.hasWork = true;
        thread.notify();
      }
    }
    
    // Wait for all the sub-threads to complete
    for (WorkerThread thread : this.threads) {
      synchronized (thread) {
        while (!thread.workDone) {
          try {
            thread.wait();
          } catch (InterruptedException ix) {
            ix.printStackTrace();
          }
        }
        thread.workDone = false;
      }
    }
    
    // The colors array should be fully updated now,
    // each worker thread will have updated its own portion
  }
  
  // Your subclass should extend this method, and compute the colors only for the
  // branches specified, taking care to note that you are running in a unique
  // thread context and should not be depending upon or modifying global state that
  // would affect how *other* branches are rendered!
  abstract void runThread(List<Branch> branches, double deltaMs); /* {
    for (Branch branch : branches) {
      // Per-branch computation, e.g.
      for (Leaf leaf : branch.leaves) {
        // Per-leaf computation, e.g.
        setColor(leaf, computedColor);
      }
    }
  } */
  
  // Implementation details of the individual worker threads
  class WorkerThread extends Thread {
    
    final List<Branch> branches = new ArrayList<Branch>();
    boolean hasWork = false;
    boolean workDone = false;
    
    WorkerThread(String name) {
      super(name);
    }
    
    public void run() {
      while (!isInterrupted()) {
        // Wait until we have work to do...
        synchronized (this) {
          try {
            while (!this.hasWork) {
              wait();
            }
          } catch (InterruptedException ix) {
            // Channel is finished
            break;
          }
          this.hasWork = false;
        }
        
        // Do our work
        runThread(this.branches, deltaMs);
        
        // Signal to the main thread that we are done
        synchronized (this) {
          this.workDone = true;
          notify();
        }
      }
    }
  }
}

public class TestThreadedPattern extends ThreadedPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public TestThreadedPattern(LX lx) {
    super(lx);
  }
  
  public void runThread(List<Branch> branches, double deltaMs) {
    for (Branch branch : branches) {
      for (Leaf leaf : branch.leaves) {
        setColor(leaf, #ff0000);
      }
    }
  }
}