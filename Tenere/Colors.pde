public class ColorSpread extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public ColorSpread(LX lx) {
    super(lx);
  }
  
  public void run(double deltaMs) {
    float hue = palette.getHuef();
    float sat = palette.getSaturationf();
    float spreadX = palette.spreadX.getValuef();
    float spreadY = palette.spreadY.getValuef();
    float spreadZ = palette.spreadZ.getValuef();
    float offsetX = palette.offsetX.getValuef();
    float offsetY = palette.offsetY.getValuef();
    float offsetZ = palette.offsetZ.getValuef();
    boolean mirror = palette.mirror.isOn();
    for (Leaf leaf : tree.leaves) {
      float dx = leaf.point.xn - .5 - offsetX;
      float dy = leaf.point.yn - .5 - offsetY;
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