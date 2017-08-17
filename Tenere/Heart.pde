public abstract class HeartPattern extends TenerePattern {
  
  protected final int[] RAINBOW = HEART_COLORS;
  
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
    
  private final LXModulator[] boundary = new LXModulator[sensors.sensor.length - 1];
  private final float[] boundaryf = new float[this.boundary.length];
    
  public final CompoundParameter baseSaturation =
    new CompoundParameter("BaseSat", 40, 0, 60)
    .setDescription("Base level of saturation");
    
  public final CompoundParameter baseBrightness =
    new CompoundParameter("BaseBrt", 40, 0, 60)
    .setDescription("Base level of brightness");    
    
  public final CompoundParameter decay =
    new CompoundParameter("Decay", 2500, 1000, 4000)
    .setDescription("Decay of the beat effect");
    
  public final CompoundParameter blend =
    new CompoundParameter("Blend", .2, .1, .8)
    .setDescription("Blend between stripes");    
    
  public final CompoundParameter xSlope = (CompoundParameter)
    new CompoundParameter("XSlope", 0, -.3, .3)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Slope on X-axis");
    
  public final CompoundParameter zSlope = (CompoundParameter)
    new CompoundParameter("ZSlope", 0, -.3, .3)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Slope on Z-axis");    
  
  private final TextureWave wave = new TextureWave(lx);
  
  public HeartPride(LX lx) {
    super(lx);
    addParameter("baseSaturation", this.baseSaturation);
    addParameter("baseBrightness", this.baseBrightness);
    addParameter("decay", this.decay);
    addParameter("blend", this.blend);
    addParameter("xSlope", this.xSlope);
    addParameter("zSlope", this.zSlope);
    
    for (int i = 0; i < this.boundary.length; ++i) {
      float base = .1 + .8 * ((i+1) / (float) (this.boundary.length + 1));
      boundary[i] = startModulator(new SinLFO(
        base - .05,
        base + .05,
        startModulator(
          new SinLFO(9000 - 300*i, 17000 + 400*i, 15000 + 1000*i).randomBasis()
        )
      ).randomBasis());
    }
    
    this.wave.speed.setNormalized(.1);
    for (int i = 0; i < this.sat.length; ++i) {
      final LinearEnvelope sat = (LinearEnvelope) addModulator(new LinearEnvelope(0, 0, this.decay)); 
      this.sat[i] = sat;
      final LinearEnvelope brt = (LinearEnvelope) addModulator(new LinearEnvelope(0, 0, this.decay)); 
      this.brt[i] = brt;
      sensors.sensor[i].heartBeat.addListener(new LXParameterListener() {
        public void onParameterChanged(LXParameter p) {
          if (p.getValue() > 0) {
            sat.setStartValue(100).trigger();
            brt.setStartValue(100).trigger();
          }
        }
      });
    }
  }
  
  public void run(double deltaMs) {
    float baseSaturation = this.baseSaturation.getValuef();
    float baseBrightness = this.baseBrightness.getValuef();
    for (int i = 0; i < this.sat.length; ++i) {
      this.satf[i] = min(100, baseSaturation + this.sat[i].getValuef());
      this.brtf[i] = min(100, baseBrightness + this.brt[i].getValuef());
    }
    for (int i = 0; i < this.boundary.length; ++i) {
      this.boundaryf[i] = this.boundary[i].getValuef();
    }
    float xSlope = this.xSlope.getValuef();
    float zSlope = this.zSlope.getValuef();
    float blend = this.blend.getValuef();
    float blendThreshold = 1 - blend;
    float blendMultiply = 1 / blend;
    
    for (LeafAssemblage assemblage : model.assemblages) {
      float prevBoundary = 0;
      int index = 0;
      float lerp = 0;
      for (float boundary : boundaryf) {
        float slope = (.5 - assemblage.points[0].xn) * xSlope + (.5 - assemblage.points[0].zn) * zSlope;
        float pb = prevBoundary + (index > 0 ? slope : 0);
        float bb = boundary + slope;
        lerp = (assemblage.points[0].yn - pb) / (bb - pb);
        if (lerp < 1) {
          if (lerp < blend) {
            if (index > 0) {
              --index;
              lerp = .5 + .5 * blendMultiply * lerp;
            } else {
              lerp = 0;
            }
          } else if (lerp > blendThreshold) {
            lerp = .5 * blendMultiply * (lerp - blendThreshold);
          } else {
            lerp = 0;
          }
          break;
        }
        ++index;
        lerp = 0;
        prevBoundary = boundary;
      }
      float hue = RAINBOW[index];
      if (lerp > 0) {
        float hue2 = RAINBOW[index+1];
        if (hue > hue2) {
          hue2 += 360;
        }
        hue = lerp(hue, hue2, lerp);
      }
      setColor(assemblage, LXColor.hsb(hue, this.satf[index], this.brtf[index])); 
    }
    
    // TODO(mcslee): consider improving this, hacky as fuck.
    wave.loop(deltaMs);
    MultiplyBlend.multiply(this.colors, wave.getColors(), 1, this.colors);
  }
}

public class HeartRings extends WavePattern {
  
  public final CompoundParameter decay =
    new CompoundParameter("Decay", 800, 250, 4000)
    .setDescription("Decay of the heart beats");
    
  public final CompoundParameter base =
    new CompoundParameter("Base", 20, 0, 40)
    .setDescription("Base brightness");
    
  public final CompoundParameter pulse =
    new CompoundParameter("Pulse", 2000, 5000, 1000)
    .setDescription("Base pulse speed");    
  
  public final LinearEnvelope[] beats = new LinearEnvelope[sensors.sensor.length];
  
  public final LXModulator foundation = startModulator(new SinLFO(0, base, pulse));
  
  public HeartRings(LX lx) {
    super(lx);
    addParameter("decay", this.decay);
    addParameter("base", this.base);
    addParameter("pulse", this.pulse);
    for (int i = 0; i < beats.length; ++i) {
      final LinearEnvelope env = beats[i] = (LinearEnvelope) addModulator(new LinearEnvelope(0, 0, decay));
      sensors.sensor[i].heartBeat.addListener(new LXParameterListener() {
        public void onParameterChanged(LXParameter p) {
          env.setRange(100, 0).trigger();
        }
      });
    }
  }
  
  public int getColor() {
    int c = LXColor.gray(foundation.getValuef());
    for (int i = 0; i < this.beats.length; ++i) {
      float heartLevel = this.beats[i].getValuef();
      if (heartLevel > 0) {
        c = LXColor.add(c, LXColor.hsb(HEART_COLORS[i], 100, heartLevel));
      }
    }
    return c;
  }
}