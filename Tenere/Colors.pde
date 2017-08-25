public class ColorLighthouse extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 17000, 19000, 5000)
    .setExponent(2)
    .setDescription("Speed of lighthouse motion");
    
  public final CompoundParameter spread = (CompoundParameter)
    new CompoundParameter("Spread", 0, 360)
    .setDescription("Spread of lighthouse gradient");
    
  public final CompoundParameter slope = (CompoundParameter)
    new CompoundParameter("Slope", 0, -1, 1)
    .setDescription("Slope of gradient");
 
  private final LXModulator spreadDamped = startModulator(new DampedParameter(this.spread, 360, 540, 270));
  private final LXModulator slopeDamped = startModulator(new DampedParameter(this.slope, 2, 4, 2));
 
  private final LXModulator azimuth = startModulator(new SawLFO(0, TWO_PI, speed));
  
  public ColorLighthouse(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("spread", this.spread);
    addParameter("slope", this.slope);
  }
  
  public void run(double deltaMs) {
    float hue = palette.getHuef();
    float sat = palette.getSaturationf();
    float azimuth = this.azimuth.getValuef();
    float spread = this.spreadDamped.getValuef() / PI;
    float slope = PI * this.slopeDamped.getValuef();
    for (Leaf leaf : model.leaves) {
      float az = (TWO_PI + leaf.point.azimuth + abs(leaf.point.yn - .5) * slope) % TWO_PI;
      float d = LXUtils.wrapdistf(az, azimuth, TWO_PI);
      setColor(leaf, LXColor.hsb(
        hue + spread * d,
        sat,
        100
      ));
    }
  }
}

public class ColorTwoToneLeaves extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter tone =
    new CompoundParameter("Hue", 0, 0, 360)
    .setDescription("Second hue to be mixed in with the first");
    
  public final CompoundParameter amount =
    new CompoundParameter("Amount", 0)
    .setDescription("Amount to mix in the second color tone");
  
  private final float[] bias = new float[model.leaves.size()]; 
  
  public ColorTwoToneLeaves(LX lx) {
    super(lx);
    addParameter("tone", this.tone);
    addParameter("amount", this.amount);
    for (int i = 0; i < this.bias.length; ++i) {
      this.bias[i] = random(0, 1);
    }
  }
  
  public void run(double deltaMs) {
    float sat = palette.getSaturationf();
    int c1 = LXColor.hsb(palette.getHuef(), sat, 100);
    int c2 = LXColor.hsb(this.tone.getValuef(), sat, 100);
    int li = 0;
    float amount = this.amount.getValuef();
    for (Leaf leaf : model.leaves) {
      float delta = amount - this.bias[li];
      if (delta <= 0) {
        setColor(leaf, c1);
      } else if (delta < .1) {
        setColor(leaf, LXColor.lerp(c1, c2, 10*delta));
      } else {
        setColor(leaf, c2);
      }   
      ++li;
    }
  }
}

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
  
  private final LXModulator spread = startModulator(new DampedParameter(palette.spread, 720, 720));
  private final LXModulator spreadX = startModulator(new DampedParameter(palette.spreadX, 2, 2));
  private final LXModulator spreadY = startModulator(new DampedParameter(palette.spreadY, 2, 2));
  private final LXModulator spreadZ = startModulator(new DampedParameter(palette.spreadZ, 2, 2));
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
    float spread = this.spread.getValuef();
    float spreadX = spread * this.spreadX.getValuef();
    float spreadY = spread * this.spreadY.getValuef();
    float spreadZ = spread * this.spreadZ.getValuef();
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
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 8000, 15000, 1000)
    .setExponent(.5)
    .setDescription("Speed of hue motion thru the assemblage");
    
  private final LXModulator spread = startModulator(new DampedParameter(palette.spread, 360, 540));
  
  private final int[] rawGradient = new int[LeafAssemblage.NUM_LEAVES];
  private final int[] assemblageGradient = new int[LeafAssemblage.NUM_LEAVES]; 
  
  public final LXModulator offset = startModulator(new SawLFO(0, LeafAssemblage.NUM_LEAVES, speed));
    
  public ColorGradientAssemblage(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
  }  
  
  public void run(double deltaMs) {
    float hue = palette.getHuef();
    float sat = palette.getSaturationf();
    float spread = this.spread.getValuef() / LeafAssemblage.NUM_LEAVES;
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

public class ColorGreenLeaves extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter range = new CompoundParameter("Range", 30, 15, 45);
  
  public ColorGreenLeaves(LX lx) {
    super(lx);
    addParameter("range", this.range);
  }
  
  public void run(double deltaMs) {
    float sat = palette.getSaturationf();
    int li = 0;
    int range = (int) this.range.getValuef();
    for (Leaf leaf : tree.leaves) {
      setColor(leaf, LXColor.hsb(140 - li % range, sat, 100));
      ++li;
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

public class ColorFixed extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter hue = new CompoundParameter("Hue", 0, 360);
  
  public ColorFixed(LX lx) {
    super(lx);
    addParameter("hue", this.hue);
  }
  
  public void run(double deltaMs) {
    setColors(LXColor.hsb(this.hue.getValuef(), 100, 100));
  }
}

public abstract class ColorSlideshow extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
    
  public final CompoundParameter rate =
    new CompoundParameter("Rate", 3000, 10000, 250);

  private final SawLFO lerp = (SawLFO) startModulator(new SawLFO(0, 1, rate));

  private int imageIndex;
  private final PImage[] images;
  
  public ColorSlideshow(LX lx) {
    super(lx);
    String[] paths = getPaths();
    this.images = new PImage[paths.length];
    for (int i = 0; i < this.images.length; ++i) {
      this.images[i] = loadImage(paths[i]);
      this.images[i].loadPixels();
    }
    addParameter("rate", this.rate);
    this.imageIndex = 0;
  }
  
  abstract String[] getPaths();
  
  public void run(double deltaMs) {
    float lerp = this.lerp.getValuef();
    if (this.lerp.loop()) {
      this.imageIndex = (this.imageIndex + 1) % this.images.length;
    }
    PImage image1 = this.images[this.imageIndex];
    PImage image2 = this.images[(this.imageIndex + 1) % this.images.length];
    
    for (Leaf leaf : model.leaves) {
      int c1 = image1.get(
        (int) (leaf.point.xn * (image1.width-1)),
        (int) ((1-leaf.point.yn) * (image1.height-1))
      );
      int c2 = image2.get(
        (int) (leaf.point.xn * (image2.width-1)),
        (int) ((1-leaf.point.yn) * (image2.height-1))
      );
      setColor(leaf, LXColor.lerp(c1, c2, lerp));
    }
  }
}

public class ColorSlideshowClouds extends ColorSlideshow {
  public ColorSlideshowClouds(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "clouds1.jpeg",
      "clouds2.jpeg",
      "clouds3.jpeg"
      
    };
  }
}

public class ColorSlideshowSunsets extends ColorSlideshow {
  public ColorSlideshowSunsets(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "sunset1.jpeg",
      "sunset2.jpeg",
      "sunset3.jpeg",
      "sunset4.jpeg",
      "sunset5.jpeg",
      "sunset6.jpeg"
    };
  }
}

public class ColorSlideshowOceans extends ColorSlideshow {
  public ColorSlideshowOceans(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "ocean1.jpeg",
      "ocean2.jpeg",
      "ocean3.jpeg",
      "ocean4.jpeg"
    };
  }
}

public class ColorSlideshowCorals extends ColorSlideshow {
  public ColorSlideshowCorals(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "coral1.jpeg",
      "coral2.jpeg",
      "coral3.jpeg",
      "coral4.jpeg",
      "coral5.jpeg",
    };
  }
}