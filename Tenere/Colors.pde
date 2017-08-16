public class ColorGradientTree extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter slopeX = (CompoundParameter)
    new CompoundParameter("SlpX", 0, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Slope of gradient on X-axis");
    
  public final CompoundParameter slopeZ = (CompoundParameter)
    new CompoundParameter("SlpZ", 0, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Slope of gradient on Z-axis");    
  
  private final LXModulator spreadX = startModulator(new DampedParameter(palette.spreadX, 720, 720));
  private final LXModulator spreadY = startModulator(new DampedParameter(palette.spreadY, 720, 720));
  private final LXModulator spreadZ = startModulator(new DampedParameter(palette.spreadZ, 720, 720));
  private final LXModulator offsetX = startModulator(new DampedParameter(palette.offsetX, 5, 5));
  private final LXModulator offsetY = startModulator(new DampedParameter(palette.offsetY, 5, 5));
  private final LXModulator offsetZ = startModulator(new DampedParameter(palette.offsetZ, 5, 5));
    
  public ColorGradientTree(LX lx) {
    super(lx);
    addParameter("slopeX", this.slopeX);
    addParameter("slopeZ", this.slopeZ);
  }
  
  public void run(double deltaMs) {
    float hue = palette.getHuef();
    float sat = palette.getSaturationf();
    float spreadX = this.spreadX.getValuef();
    float spreadY = this.spreadY.getValuef();
    float spreadZ = this.spreadZ.getValuef();
    float offsetX = this.offsetX.getValuef();
    float offsetY = this.offsetY.getValuef();
    float offsetZ = this.offsetZ.getValuef();
    float slopeX = this.slopeX.getValuef();
    float slopeZ = this.slopeZ.getValuef();
    boolean mirror = palette.mirror.isOn();
    for (Leaf leaf : tree.leaves) {
      float dx = leaf.point.xn - .5 - offsetX;
      float dy = leaf.point.yn - .5 - offsetY + slopeX * (.5 - leaf.point.xn) + slopeZ * (.5 - leaf.point.zn);
      float dz = leaf.point.zn - .5 - offsetZ;
      if (mirror) {
        dx = abs(dx);
        dy = abs(dy);
        dz = abs(dz);
      }
      setColor(leaf, LXColor.hsb(
        hue + spreadX*dx + spreadY*dy + spreadZ*dz,
        sat,
        100
      ));
    }
  }
}

public class ColorGradientAssemblage extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter spread =
    new CompoundParameter("Spread", 0, 360)
    .setDescription("Amount of hue spread across the assemblage");

  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 8000, 15000, 1000)
    .setExponent(.5)
    .setDescription("Speed of hue motion thru the assemblage");
  
  private final int[] rawGradient = new int[LeafAssemblage.NUM_LEAVES];
  private final int[] assemblageGradient = new int[LeafAssemblage.NUM_LEAVES]; 
  
  public final LXModulator offset = startModulator(new SawLFO(0, LeafAssemblage.NUM_LEAVES, speed));
  public final LXModulator spreadDamped = startModulator(new DampedParameter(this.spread, 360, 540));
    
  public ColorGradientAssemblage(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("spread", this.spread);
  }
  
  public void run(double deltaMs) {
    float hue = palette.getHuef();
    float sat = palette.getSaturationf();
    float spread = this.spreadDamped.getValuef() / LeafAssemblage.NUM_LEAVES;
    float offset = this.offset.getValuef();
    float offsetLerp = offset % 1;
    int offsetFloor = (int) offset;
    for (int i = 0; i < LeafAssemblage.NUM_LEAVES; ++i) {
      this.rawGradient[i] = LXColor.hsb(hue + spread * i, sat, 100);
    }
    for (int i = 0; i < LeafAssemblage.NUM_LEAVES; ++i) {      
      int i1 = (i + offsetFloor) % LeafAssemblage.NUM_LEAVES;
      int i2 = (i + offsetFloor + 1) % LeafAssemblage.NUM_LEAVES;
      this.assemblageGradient[i] = LXColor.lerp(this.rawGradient[i1], this.rawGradient[i2], offsetLerp); 
    }
    for (LeafAssemblage assemblage : model.assemblages) {
      int li = 0;
      for (Leaf leaf : assemblage.leaves) {
        setColor(leaf, this.assemblageGradient[li++]);
      }
    }
  }
}

public class ColorRain extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 1, 5)
    .setDescription("Speed of the rainfall");
    
  public final CompoundParameter range = (CompoundParameter)
    new CompoundParameter("Range", 30, 5, 50)
    .setDescription("Range of blue depth");

  private static final int BUCKETS = 37;
  private final float[][] buckets = new float[BUCKETS+1][BUCKETS+1];

  public ColorRain(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("range", this.range);
    for (int i = 0; i < BUCKETS+1; ++i) {
      for (int j = 0; j < BUCKETS+1; ++j) {
        this.buckets[i][j] = random(1);
      }
    }
  }
  
  private double accum = 0;
  
  public void run(double deltaMs) {
    int range = (int) this.range.getValue();
    accum += this.speed.getValue() * .02 * deltaMs;
    float saturation = palette.getSaturationf();
    for (Leaf leaf : model.leaves) {
      float offset = this.buckets[(int) (BUCKETS * leaf.point.xn)][(int) (BUCKETS * leaf.point.zn)];
      int hMove = ((int) (180 * leaf.point.yn + 120 * offset + accum)) % 80;
      if (hMove > range) {
        hMove = max(0, range - 8*(hMove - range));
      }
      setColor(leaf, LXColor.hsb(
        210 - hMove,
        saturation,
        100
      ));
    }
  }
}

public class ColorAutumn extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter range = new CompoundParameter("Range", 30, 15, 45); 
  
  public ColorAutumn(LX lx) {
    super(lx);
    addParameter("range", this.range);
  }
  
  public void run(double deltaMs) {
    float sat = palette.getSaturationf();
    int li = 0;
    int range = (int) this.range.getValuef();
    for (Leaf leaf : tree.leaves) {
      setColor(leaf, LXColor.hsb(li % range, sat, 100));
      ++li;
    }
  }
}

public class ColorSwirl extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
    
  private float basis = 0;
  
  public final CompoundParameter speed =
    new CompoundParameter("Speed", .5, 0, 2);
      
  public final CompoundParameter slope = 
    new CompoundParameter("Slope", 1, .2, 3);    
    
  public final DiscreteParameter amount =
    new DiscreteParameter("Amount", 3, 1, 5)
    .setDescription("Amount of swirling around the center");    
  
  public ColorSwirl(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("slope", this.slope);
    addParameter("amount", this.amount);
  }
  
  public void run(double deltaMs) {
    this.basis = (float) (this.basis + .001 * speed.getValuef() * deltaMs) % TWO_PI;
    float slope = this.slope.getValuef();
    float sat = palette.getSaturationf();
    int amount = this.amount.getValuei();
    for (Leaf leaf : tree.leaves) {
      float hb1 = (this.basis + leaf.point.azimuth - slope * (1 - leaf.point.yn)) / TWO_PI;
      setColor(leaf, LXColor.hsb(
        (this.basis + leaf.point.azimuth - slope * (1 - leaf.point.yn)) / TWO_PI * 360 * amount,
        sat,
        100
      )); 
    }
  }
}