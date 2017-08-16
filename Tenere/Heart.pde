public abstract class HeartPattern extends TenerePattern {
  
  protected final int[] RAINBOW = {
    350, 20, 80, 200, 280,
  };
  
  public String getAuthor() {
    return "Mark C. Slee";
  }
    
  protected HeartPattern(LX lx) {
    super(lx);
  }
}

public class HeartLoops extends HeartPattern {
  
  private final Heart[] hearts = new Heart[sensors.sensor.length];
  
  public final CompoundParameter baseSaturation =
    new CompoundParameter("BaseSat", 40, 0, 60)
    .setDescription("Base level of saturation");
    
  public final CompoundParameter decay =
    new CompoundParameter("Decay", 2500, 1000, 4000)
    .setDescription("Decay of the beat effect");    
  
  public HeartLoops(LX lx) {
    super(lx);
    addParameter("baseSaturation", this.baseSaturation);
    addParameter("decay", this.decay);
    for (int i = 0; i < hearts.length; ++i) {
      addLayer(this.hearts[i] = new Heart(lx, RAINBOW[i], sensors.sensor[i]));
    }
    int branchesPerHeart = tree.branches.size() / this.hearts.length;
    int bi = 0;
    for (Branch branch : tree.branches) {
      this.hearts[bi++ / branchesPerHeart].branches.add(branch);
    }
  }
  
  class Heart extends LXLayer {
    
    private final int hue;
    private final Sensors.Sensor sensor;
    
    private final List<Branch> branches = new ArrayList<Branch>();
    private final int[] leafMask = new int[Leaf.NUM_LEDS];

    private final LinearEnvelope heartSat = (LinearEnvelope) addModulator(new LinearEnvelope(0, 0, 2000));
    private final LinearEnvelope heartSpeed = (LinearEnvelope) addModulator(new LinearEnvelope(2500, 2500, decay));
    
    private final LXModulator heartSatDamped = startModulator(new DampedParameter(this.heartSat, 1000));
    private final LXModulator heartSpeedDamped = startModulator(new DampedParameter(this.heartSpeed, 50000));
    
    public LXModulator pos = startModulator(new SawLFO(0, Leaf.NUM_LEDS, heartSpeedDamped));

    Heart(LX lx, int hue, final Sensors.Sensor sensor) {
      super(lx);
      this.hue = hue;
      this.sensor = sensor;
      sensor.heartBeat.addListener(new LXParameterListener() {
        public void onParameterChanged(LXParameter p) {
          heartSat.setRange(100, 0).trigger();
          heartSpeed.setRange(200, 2500).trigger();
        }
      });
    }
            
    public void run(double deltaMs) {
      float pos = this.pos.getValuef();
      float falloff = 50;
      float heartSat = min(100, baseSaturation.getValuef() + this.heartSatDamped.getValuef());
      for (int i = 0; i < this.leafMask.length; ++i) {
        this.leafMask[i] = LXColor.hsb(
          this.hue + 39*i % 17,
          heartSat,
          max(0, 100 - falloff * LXUtils.wrapdistf(i, pos, Leaf.NUM_LEDS))
        );
      }
      for (Branch branch : this.branches) {
        for (Leaf leaf : branch.leaves) {
          for (int i = 0; i < Leaf.NUM_LEDS; ++i) {
            this.colors[leaf.point.index + i] = this.leafMask[i];
          }
        }
      }
    }
  }
  
  public void run(double deltaMs) {}
  
}

public class HeartPride extends HeartPattern {
  
  private final LinearEnvelope sat[] = new LinearEnvelope[sensors.sensor.length];
  private final float satf[] = new float[this.sat.length];
  
  private final LinearEnvelope brt[] = new LinearEnvelope[sensors.sensor.length];
  private final float brtf[] = new float[this.brt.length];
  
  public final CompoundParameter baseSaturation =
    new CompoundParameter("BaseSat", 40, 0, 60)
    .setDescription("Base level of saturation");
    
  public final CompoundParameter baseBrightness =
    new CompoundParameter("BaseBrt", 40, 0, 60)
    .setDescription("Base level of brightness");    
    
  public final CompoundParameter decay =
    new CompoundParameter("Decay", 2500, 1000, 4000)
    .setDescription("Decay of the beat effect");
  
  private final TextureWave wave = new TextureWave(lx);
  
  public HeartPride(LX lx) {
    super(lx);
    addParameter("baseSaturation", this.baseSaturation);
    addParameter("baseBrightness", this.baseBrightness);
    addParameter("decay", this.decay);
    this.wave.speed.setNormalized(.1);
    for (int i = 0; i < sat.length; ++i) {
      final LinearEnvelope sat = (LinearEnvelope) addModulator(new LinearEnvelope(this.baseSaturation, this.baseSaturation, this.decay)); 
      this.sat[i] = sat;
      final LinearEnvelope brt = (LinearEnvelope) addModulator(new LinearEnvelope(this.baseBrightness, this.baseBrightness, this.decay)); 
      this.brt[i] = brt;
      sensors.sensor[i].heartBeat.addListener(new LXParameterListener() {
        public void onParameterChanged(LXParameter p) {
          if (p.getValue() > 0) {
            sat.setStartValue(140).trigger();
            brt.setStartValue(120).trigger();
          }
        }
      });
    }
  }
  
  public void run(double deltaMs) {
    for (int i = 0; i < this.sat.length; ++i) {
      this.satf[i] = min(100, this.sat[i].getValuef());
      this.brtf[i] = min(100, this.brt[i].getValuef());
    }
    for (Leaf leaf : model.leaves) {
      int index = ((int) (this.sat.length * leaf.point.yn)) % this.sat.length;
      setColor(leaf, LXColor.hsb(RAINBOW[index], this.satf[index], this.brtf[index])); 
    }
    
    // TODO(mcslee): improve this, hacky as fuck.
    wave.loop(deltaMs);
    MultiplyBlend.multiply(this.colors, wave.getColors(), 1, this.colors);
  }
}