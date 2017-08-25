public class BigwillLimboRandom extends LXPattern {
  public final CompoundParameter rate =
    new CompoundParameter("Rate", 500, 100, 1000)
    .setDescription("Rate at which the limb selection changes");

  public final CompoundParameter hueRate =
    new CompoundParameter("Color Rate", 500 / 3.0, 100 / 3.0, 1000 / 3.0)
    .setDescription("Rate at which the color changes");

  public final CompoundParameter satBase =
    new CompoundParameter("Sat Base", 70, 0, 100)
    .setDescription("Saturation Base Value");

  public final CompoundParameter satRange =
    new CompoundParameter("Sat Range", 25,  0, 100)
    .setDescription("Saturation range above base value");

  public final CompoundParameter brightBase =
    new CompoundParameter("Bright Base", 75, 0, 100)
    .setDescription("Brightness base Value");

  public final CompoundParameter brightRange =
    new CompoundParameter("Bright Range", 25, 0, 100)
    .setDescription(" Brightness range above base value");

  public final CompoundParameter numLimbs =
    new CompoundParameter("Density", 5, 1, tree.limbs.size())
    .setDescription("Probable number of limbs to light up");

  private final Click click = new Click(this.rate);
  private final LXRangeModulator hueMod = new SawLFO(0, 360, this.hueRate);

  private HashMap<Limb, Boolean> limbOn;
  private HashMap<Limb, Float> limbHue;

  public BigwillLimboRandom(LX lx) {
    super(lx);

    limbOn = new HashMap<Limb, Boolean>();
    limbHue = new HashMap<Limb, Float>();

    addParameter(this.rate);
    addParameter(this.hueRate);    
    addParameter(this.satBase);
    addParameter(this.satRange);
    addParameter(this.brightBase);
    addParameter(this.brightRange);
    addParameter(this.numLimbs);
    startModulator(this.click);

    for (Limb limb : tree.limbs) {
      limbOn.put(limb, false);
      limbHue.put(limb, 0.0);
    }
  }
  
  public void run(double deltaMs) {
    if (click.click()) {
      for (Limb limb : tree.limbs) {
         if ((int) (Math.random() * (float) tree.limbs.size() / this.numLimbs.getValuef()) == 0) {
          limbOn.put(limb, true);
          limbHue.put(limb, (float) Math.random() * 360);
         } else {
          limbOn.put(limb, false);
         }
      }
    }

    for (Limb limb : tree.limbs) {
      if (limbOn.get(limb)) {
        float sat = Math.max(0, Math.min(100, this.satBase.getValuef() + this.satRange.getValuef()));
        float bright = Math.max(0, Math.min(100, this.brightBase.getValuef() + this.brightRange.getValuef()));
        setColor(limb, LX.hsb(limbHue.get(limb), sat, bright));
      } else {
        setColor(limb, #000000);
      }
    }
  } 
}

public class BigwillAssemblageCrawl extends LXPattern {
  public final CompoundParameter rate =
    new CompoundParameter("Crawl Rate", 1200, 100, 4000)
    .setDescription("Rate at which the assemblages are crawled through");

  public final CompoundParameter hueRate =
    new CompoundParameter("Hue Rate", 1200, 100, 4000)
    .setDescription("Rate at which the color space is traversed");

  public final CompoundParameter satBase =
    new CompoundParameter("Sat Base", 70, 0, 100)
    .setDescription("Saturation Base Value");

  public final CompoundParameter satRange =
    new CompoundParameter("Sat Range", 25,  0, 100)
    .setDescription("Saturation range above base value");

  public final CompoundParameter brightBase =
    new CompoundParameter("Bright Base", 75, 0, 100)
    .setDescription("Brightness base Value");

  public final CompoundParameter brightRange =
    new CompoundParameter("Bright Range", 25, 0, 100)
    .setDescription(" Brightness range above base value");

  private final LXRangeModulator leafMod = new SawLFO(0, LeafAssemblage.NUM_LEAVES, this.rate);
  private final LXRangeModulator hueMod = new SawLFO(0, 360, this.hueRate);

  private int c;

  public BigwillAssemblageCrawl(LX lx) {
    super(lx);
    addParameter(this.rate);
    addParameter(this.hueRate);    
    addParameter(this.satBase);
    addParameter(this.satRange);
    addParameter(this.brightBase);
    addParameter(this.brightRange);
    startModulator(this.leafMod);
    startModulator(this.hueMod);
  }
  
  public void run(double deltaMs) {

    for (LeafAssemblage leafAss : tree.assemblages) {
      Leaf currentLeaf = leafAss.leaves.get(Math.min(LeafAssemblage.NUM_LEAVES-1, (int)leafMod.getValuef()));

      for (Leaf leaf : leafAss.leaves) {
        if (leaf == currentLeaf) {
          float sat = Math.max(0, Math.min(100, this.satBase.getValuef() + this.satRange.getValuef()));
          float bright = Math.max(0, Math.min(100, this.brightBase.getValuef() + this.brightRange.getValuef()));
          this.c = LX.hsb(this.hueMod.getValuef(), sat, bright);

          setColor(leaf, c);
        } else {
          setColor(leaf, #000000);
        }
      }
    }
  } 
}

public class BigwillSweeper extends LXPattern {
  public final CompoundParameter rate =
    new CompoundParameter("Rate", 1600, 100, 4000)
    .setDescription("Rate at which the sweeping effect crosses the tree");

  public final CompoundParameter satBase =
    new CompoundParameter("Sat Base", 70, 0, 100)
    .setDescription("Saturation Base Value");

  public final CompoundParameter satRange =
    new CompoundParameter("Sat Range", 25,  0, 100)
    .setDescription("Saturation range above base value");

  public final CompoundParameter brightBase =
    new CompoundParameter("Bright Base", 75, 0, 100)
    .setDescription("Brightness base Value");

  public final CompoundParameter brightRange =
    new CompoundParameter("Bright Range", 25, 0, 100)
    .setDescription(" Brightness range above base value");

  private final LXRangeModulator leafMod = new SawLFO(-Tree.LIMB_HEIGHT*2.0, Tree.LIMB_HEIGHT*2.0, this.rate);
  private int c;

  public BigwillSweeper(LX lx) {
    super(lx);
    addParameter(this.rate);
    addParameter(this.satBase);
    addParameter(this.satRange);
    addParameter(this.brightBase);
    addParameter(this.brightRange);
    startModulator(this.leafMod);
    newColor();
  }

  public void newColor() {
      float sat = Math.max(0, Math.min(100, this.satBase.getValuef() + this.satRange.getValuef()));
      float bright = Math.max(0, Math.min(100, this.brightBase.getValuef() + this.brightRange.getValuef()));
      this.c = LX.hsb((float) Math.random() * 360, sat, bright);    
  }  
  public void run(double deltaMs) {

    if (leafMod.loop()) {
      newColor();
    }

    for (LeafAssemblage leafAss : tree.assemblages) {
      for (Leaf leaf : leafAss.leaves) {
        if (leafMod.getValuef() - 3*IN <= leaf.x && leaf.x <= leafMod.getValuef() + 3*IN) {
          setColor(leaf, c);
        } else {
          setColor(leaf, #000000);
        }
      }
    }
  } 
}

public class BigwillBeams extends LXPattern {
  public final CompoundParameter sweepRate =
    new CompoundParameter("Sweep Rate", 1600, 100, 4000)
    .setDescription("Rate at which the beam moves around the tree");

  public final CompoundParameter inclineRate =
    new CompoundParameter("Incline Rate", 1600, 100, 4000)
    .setDescription("Rate at which the beam moves around the tree");

  public final CompoundParameter coneRadius =
    new CompoundParameter("Cone Size", PI / 8.0, PI / 45.0, PI / 4.0)
    .setDescription("Rate at which the beam moves around the tree");

  public final CompoundParameter satBase =
    new CompoundParameter("Sat Base", 70, 0, 100)
    .setDescription("Saturation Base Value");

  public final CompoundParameter satRange =
    new CompoundParameter("Sat Range", 25,  0, 100)
    .setDescription("Saturation range above base value");

  public final CompoundParameter brightBase =
    new CompoundParameter("Bright Base", 75, 0, 100)
    .setDescription("Brightness base Value");

  public final CompoundParameter brightRange =
    new CompoundParameter("Bright Range", 25, 0, 100)
    .setDescription(" Brightness range above base value");

  private final LXRangeModulator thetaMod = new SinLFO(0, PI / 2.0, this.inclineRate);
  private final LXRangeModulator phiMod = new SawLFO(-PI / 2.0, PI / 2.0, this.sweepRate);
  private final LXRangeModulator hueMod = new SawLFO(0, 360, this.sweepRate);

  private int c;

  public BigwillBeams(LX lx) {
    super(lx);
    addParameter(this.sweepRate);
    addParameter(this.inclineRate);
    addParameter(this.coneRadius);
    addParameter(this.satBase);
    addParameter(this.satRange);
    addParameter(this.brightBase);
    addParameter(this.brightRange);
    startModulator(this.thetaMod);
    startModulator(this.phiMod);
    startModulator(this.hueMod);
  }

  public int newColor() {
      float sat = Math.max(0, Math.min(100, this.satBase.getValuef() + this.satRange.getValuef()));
      float bright = Math.max(0, Math.min(100, this.brightBase.getValuef() + this.brightRange.getValuef()));
      return LX.hsb((int)this.hueMod.getValuef(), sat, bright);
  }

  public boolean isLeafOn(Leaf leaf) {
    float r = (float) Math.sqrt(leaf.x * leaf.x + leaf.y * leaf.y + leaf.z * leaf.z);
    float theta = (float) Math.acos(leaf.y / r);
    float phi = (float) Math.atan(leaf.x / leaf.z);

    return (phiMod.getValuef() - coneRadius.getValuef() / 2.0 <= phi && phi <= phiMod.getValuef() + coneRadius.getValuef() / 2.0) && 
           (thetaMod.getValuef() - coneRadius.getValuef() / 2.0 <= theta && theta <= thetaMod.getValuef() + coneRadius.getValuef() / 2.0);
  }

  public void run(double deltaMs) {

    if (phiMod.loop()) {
      newColor();
    }

    for (LeafAssemblage leafAss : tree.assemblages) {
      for (Leaf leaf : leafAss.leaves) {
        if (isLeafOn(leaf)) {
          setColor(leaf, newColor());
        } else {
          setColor(leaf, #000000);
        }
      }
    }
  } 
}

public class BigwillLighthouse extends LXPattern {
  public final CompoundParameter rate =
    new CompoundParameter("Rate", 1500, 100, 4000)
    .setDescription("Rate at which the lighthouse effect crosses the tree");

  public final CompoundParameter satBase =
    new CompoundParameter("Sat Base", 70, 0, 100)
    .setDescription("Saturation Base Value");

  public final CompoundParameter satRange =
    new CompoundParameter("Sat Range", 25,  0, 100)
    .setDescription("Saturation range above base value");

  public final CompoundParameter brightBase =
    new CompoundParameter("Bright Base", 75, 0, 100)
    .setDescription("Brightness base Value");

  public final CompoundParameter brightRange =
    new CompoundParameter("Bright Range", 25, 0, 100)
    .setDescription(" Brightness range above base value");

  private final LXRangeModulator thetaMod = new TriangleLFO(0, PI, this.rate);
  private final LXRangeModulator phiMod = new SawLFO(-PI / 2.0, PI / 2.0, this.rate);
  private final LXRangeModulator hueMod = new SawLFO(0, 360, this.rate);

  private int c;

  public BigwillLighthouse(LX lx) {
    super(lx);
    addParameter(this.rate);
    addParameter(this.satBase);
    addParameter(this.satRange);
    addParameter(this.brightBase);
    addParameter(this.brightRange);
    startModulator(this.thetaMod);
    startModulator(this.phiMod);
    startModulator(this.hueMod);
  }

  public int newColor() {
      float sat = Math.max(0, Math.min(100, this.satBase.getValuef() + this.satRange.getValuef()));
      float bright = Math.max(0, Math.min(100, this.brightBase.getValuef() + this.brightRange.getValuef()));
      return LX.hsb((int)this.hueMod.getValuef(), sat, bright);
  }

  public boolean isLeafOn(Leaf leaf) {
    float phi = (float) Math.atan(leaf.x / leaf.z);
    return phiMod.getValuef() - PI / 90.0 <= phi && phi <= phiMod.getValuef() + PI / 90.0;
  }

  public void run(double deltaMs) {

    if (phiMod.loop()) {
      newColor();
    }

    for (LeafAssemblage leafAss : tree.assemblages) {
      for (Leaf leaf : leafAss.leaves) {
        if (isLeafOn(leaf)) {
          setColor(leaf, newColor());
        } else {
          setColor(leaf, #000000);
        }
      }
    }
  } 
}

public class BigwillBalloons extends LXPattern {
  private class Balloon {
    public int c;
    public float r;    
    public float x;
    public float z;
    private LXRangeModulator yMod;
    private BigwillBalloons pat;

    public Balloon(BigwillBalloons pat) {
      this.pat = pat;
      this.yMod = new SawLFO(-24*IN, Tree.LIMB_HEIGHT*2.0 + 24*IN, 0);
      newValues();
      pat.startModulator(this.yMod);
    }

    public void run() {
      if (this.yMod.loop()) {
        newValues();
      }
    }

    private void newValues() {
      newColor();
      newRadius();
      newX();
      newyModPeriod();
      newZ();
    }

    private void newyModPeriod() {
      this.yMod.setPeriod(this.pat.rate.getValuef() * (0.9 + 0.2 * (float) Math.random()));
    }

    private void newColor() {
      float sat = Math.max(0, Math.min(100, this.pat.satBase.getValuef() + this.pat.satRange.getValuef()));
      float bright = Math.max(0, Math.min(100, this.pat.brightBase.getValuef() + this.pat.brightRange.getValuef()));
      this.c = LX.hsb((float) Math.random() * 360, sat, bright);    
    }

    private void newRadius() {
      this.r = (12.0 + 12.0 * (float) Math.random())*IN;
    }

    private void newX() {
      this.x = -2.0 * Tree.LIMB_HEIGHT + Tree.LIMB_HEIGHT * 4.0 * (float) Math.random();
    }

    private void newZ() {
      this.z = -2.0 * Tree.LIMB_HEIGHT + Tree.LIMB_HEIGHT * 4.0 * (float) Math.random();
    }
  }

  private final static int MAX_BALLOONS = 100;

  public final CompoundParameter rate =
    new CompoundParameter("Rate", 3500, 1000, 5000)
    .setDescription("Average rate at which the balloons float up");

  public final CompoundParameter numBalloons =
    new CompoundParameter("Balloons", 50, 10, MAX_BALLOONS)
    .setDescription("Number of balloons");

  public final CompoundParameter backdropBrightness =
    new CompoundParameter("Backdrop", 255, 0, 255)
    .setDescription("Brightness of backdrop");

  public final CompoundParameter satBase =
    new CompoundParameter("Sat Base", 70, 0, 100)
    .setDescription("Saturation Base Value");

  public final CompoundParameter satRange =
    new CompoundParameter("Sat Range", 25,  0, 100)
    .setDescription("Saturation range above base value");

  public final CompoundParameter brightBase =
    new CompoundParameter("Bright Base", 75, 0, 100)
    .setDescription("Brightness base Value");

  public final CompoundParameter brightRange =
    new CompoundParameter("Bright Range", 25, 0, 100)
    .setDescription(" Brightness range above base value");

  private final List<Balloon> balloons = new ArrayList<Balloon>();

  public BigwillBalloons(LX lx) {
    super(lx);
    addParameter(this.rate);
    addParameter(this.numBalloons);
    addParameter(this.backdropBrightness);
    addParameter(this.satBase);
    addParameter(this.satRange);
    addParameter(this.brightBase);
    addParameter(this.brightRange);

    for (int i = 0; i < MAX_BALLOONS; i++) {
      balloons.add(new Balloon(this));
    }
  }

  public void run(double deltaMs) {
    for (Balloon b : this.balloons) {
      b.run();
    }

    for (Leaf leaf : tree.leaves) {
      int c = LX.rgb((int)this.backdropBrightness.getValuef(), (int)this.backdropBrightness.getValuef(), (int)this.backdropBrightness.getValuef());

      for (int i = 0; i < (int)this.numBalloons.getValuef(); i++) {
        Balloon b = this.balloons.get(i);
        if (Math.sqrt(Math.pow(leaf.x - b.x, 2)
                      + Math.pow(leaf.y - b.yMod.getValuef(), 2)
                      + Math.pow(leaf.z - b.z, 2)) < b.r) {
          c = b.c;
          break;
        }
      }

      setColor(leaf, c);
    }
  } 
}

public class BigwillSnow extends LXPattern {
  private class Flake {
    public int c;
    public float r;    
    public float x;
    public float z;
    private LXPeriodicModulator yMod;
    private BigwillSnow pat;

    public Flake(BigwillSnow pat) {
      this.pat = pat;
      this.c = #FFFFFF;
      this.r = 3.0*IN;
      this.yMod = new SawLFO(1.0*IN + Tree.LIMB_HEIGHT*2.0, -1.0*IN, 0).randomBasis();
      newValues();
      pat.startModulator(this.yMod);
    }

    public void run() {
      if (this.yMod.loop()) {
        newValues();
      }
    }

    private void newValues() {
      newX();
      newyModPeriod();
      newZ();
    }

    private void newyModPeriod() {
      this.yMod.setPeriod(this.pat.rate.getValuef() * (0.9 + 0.2 * (float) Math.random()));
    }

    private void newX() {
      this.x = -2.0 * Tree.LIMB_HEIGHT + Tree.LIMB_HEIGHT * 4.0 * (float) Math.random();
    }

    private void newZ() {
      this.z = -2.0 * Tree.LIMB_HEIGHT + Tree.LIMB_HEIGHT * 4.0 * (float) Math.random();
    }
  }

  private final static int MAX_FLAKES = 1000;

  public final CompoundParameter rate =
    new CompoundParameter("Rate", 3500, 1000, 5000)
    .setDescription("Average rate at which the snow flakes fall");

  public final CompoundParameter numFlakes =
    new CompoundParameter("Flakes", 500, 100, MAX_FLAKES)
    .setDescription("Number of snow flakes");

  private final List<Flake> flakes = new ArrayList<Flake>();

  private float bucket(float x, float y, float z) {
    return 17 * (float) Math.floor(x * 3*IN) + 13 * (float) Math.floor(y * 3*IN) + 11 * (float) Math.floor(z * 3*IN);
  }

  public BigwillSnow(LX lx) {
    super(lx);
    addParameter(this.rate);
    addParameter(this.numFlakes);

    for (int i = 0; i < MAX_FLAKES; i++) {
      flakes.add(new Flake(this));
    }
  }

  public void run(double deltaMs) {
    HashMap<Float, Flake> flakeMap = new HashMap<Float, Flake>();

    for (int i = 0; i < (int) this.numFlakes.getValuef(); i++) {
      Flake f = flakes.get(i);
      f.run();
      flakeMap.put(bucket(f.x, f.yMod.getValuef(), f.z), f);
    }

    for (Leaf leaf : tree.leaves) {
      int c = #000000;

      Flake f = flakeMap.get(bucket(leaf.x, leaf.y, leaf.z));
      if (f != null) {
        // System.out.println("flake hit! " + leaf.toString() + "flake: " + flake.toString());
        c = f.c;
      }

      setColor(leaf, c);
    }
  } 
}
