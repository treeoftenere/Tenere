import java.util.Random;

public static class L8onUtil {
  L8onUtil() {
  }
  
  /*
   * Use this to decrease the brightness of a light over `delay` ms.
   * The current color is reduces by the appropriate proportion given   
   * the deltaMs of the current run.   
   */   
  public static float decayed_brightness(color c, float delay,  double deltaMs) {
    float bright_prop = min(((float)deltaMs / delay), 1.0);
    float bright_diff = max((LXColor.b(c) * bright_prop), 1);
    return max(LXColor.b(c) - bright_diff, 0.0);
  }
  
  
  public static float natural_hue_blend(float hueBase, float hueNew) {
    return natural_hue_blend(hueBase, hueNew, 2);    
  }
  
  /**
   * Use this to "naturally" blend colors.   
   * Can be used iteratively on a point as more colors are "mixed" into it, or 
   * used simply with 2 colors.
   * 
   */ 
  public static float natural_hue_blend(float hueBase, float hueNew, int count) {    
    // Return hueA if there is only one hue to mix
    if(count == 1) { return hueBase; }
        
    if(count > 2) {
      // Jump color by 180 before blending again to avoid regression towards the mean (180)
      hueBase = (hueBase + 180) % 360;
    }    
    
    // Blend a with b
    float minHue = min(hueBase, hueNew);
    float maxHue = max(hueBase, hueNew);    
    return (minHue * 2.0 + maxHue / 2.0) / 2.0;    
  }
}

public class L8onBlurLayer extends LXLayer {
  public final BoundedParameter amount;
  private final int[] blurBuffer;

  public L8onBlurLayer(LX lx, LXDeviceComponent pattern) {
    this(lx, pattern, new BoundedParameter("BLUR", 0));
  }

  public L8onBlurLayer(LX lx, LXDeviceComponent pattern, BoundedParameter amount) {    
    super(lx, pattern); 
    this.amount = amount;
    this.blurBuffer = new int[lx.total];
    
    for (int i = 0; i < blurBuffer.length; ++i) {
      this.blurBuffer[i] = 0xff000000;
    }
  }
  
  public void run(double deltaMs) {
    float blurf = this.amount.getValuef();
    if (blurf > 0) {
      blurf = 1 - (1 - blurf) * (1 - blurf) * (1 - blurf);
      for (int i = 0; i < this.colors.length; ++i) {
        int blend = LXColor.screen(this.colors[i], this.blurBuffer[i]);
        this.colors[i] = LXColor.lerp(this.colors[i], blend, blurf);
      }
    }
    for (int i = 0; i < this.colors.length; ++i) {
      this.blurBuffer[i] = this.colors[i];
    }
  }
}

/**
 * Contains the current state of an explosion.
 */
public class L8onExplosion implements LXParameterListener {  
  float center_x;
  float center_y;
  float center_z;  
  float stroke_width;
  float hue_value;
  float chill_time;
  float time_chillin;

  private BooleanParameter trigger_parameter;
  public LXModulator radius_modulator;  
  private boolean radius_modulator_triggered = false;

  public L8onExplosion(LXModulator radius_modulator, BooleanParameter trigger_parameter, float stroke_width, float center_x, float center_y, float center_z) {
    this.setRadiusModulator(radius_modulator, stroke_width);
    
    this.trigger_parameter = trigger_parameter;
    this.trigger_parameter.addListener(this);
    
    this.center_x = center_x;
    this.center_y = center_y;
    this.center_z = center_z;
  }
 
  public void setChillTime(float chill_time) {
    this.chill_time = chill_time;  
    this.time_chillin = 0;
  }

  public boolean isChillin(float deltaMs) {
    this.time_chillin += deltaMs;

    return time_chillin < this.chill_time;  
  }

  public float distanceFromCenter(float x, float y, float z) {
    return dist(this.center_x, this.center_y, this.center_z, x, y, z);
  }

  public void setRadiusModulator(LXModulator radius_modulator, float stroke_width) {
    this.radius_modulator = radius_modulator;
    this.stroke_width = stroke_width;    
    this.radius_modulator_triggered = false;
  }

  public void setCenter(float x, float y, float z) {
    this.center_x = x;
    this.center_y = y;
    this.center_z = z;
  }

  public void explode() {
    this.radius_modulator_triggered = true;
    this.radius_modulator.trigger();
  }

  public boolean hasExploded() {
    return this.radius_modulator_triggered;
  }

  public boolean isExploding() {
    if (this.radius_modulator == null) {
      return false;
    }

    return this.radius_modulator.isRunning();
  }

  public boolean isFinished() {
    if (this.radius_modulator == null) {
      return true;
    }

    return !this.radius_modulator.isRunning();
  }

  public boolean onExplosion(float x, float y, float z) {
    float current_radius = this.radius_modulator.getValuef();
    float min_dist = max(0.0, current_radius - (stroke_width / 2.0));
    float max_dist = current_radius + (stroke_width / 2.0);;
    float point_dist = this.distanceFromCenter(x, y, z);

    return (point_dist >= min_dist && point_dist <= max_dist);  
  }
  
  public void onParameterChanged(LXParameter parameter) {    
    if (!(parameter == this.trigger_parameter)) { return; }
        
    if (this.trigger_parameter.getValueb() && this.isFinished()) {            
      this.setChillTime(0);
    }
  }
}

/**
 * Use this to get a beat gate that has been configured to be very sensitive to
 * the bass beat of the audio input.
 */
public class L8onAudioBeatGate extends BandGate {
  final float DEFAULT_GAIN = 7;
  final float DEFAULT_THRESHOLD = .5;
  final float DEFAULT_FLOOR = .88;
  
  public L8onAudioBeatGate(LX lx) {
    this("Beat", lx);
  }

  public L8onAudioBeatGate(String label, LX lx) {
    this(label, lx.engine.audio.meter);
  }
  
  public L8onAudioBeatGate(String label, GraphicMeter meter) {
    super(label, meter);
    this.gain.setValue(DEFAULT_GAIN);
    this.threshold.setValue(DEFAULT_THRESHOLD);
    this.floor.setValue(DEFAULT_FLOOR);    
  }
  
  public L8onAudioBeatGate(GraphicMeter meter, float minHz, float maxHz) {
    this("Beat", meter);
    setFrequencyRange(minHz, maxHz);
  }
  
  public L8onAudioBeatGate(String label, GraphicMeter meter, int minHz, int maxHz) {
    this(label, meter);
    setFrequencyRange(minHz, maxHz);
  }  
}

/**
 * Use this to get a beat gate that has been configured to be very sensitive to
 * the bass beat of the audio input.
 */
public class L8onAudioClapGate extends BandGate {
  final float DEFAULT_GAIN = 7;
  final float DEFAULT_THRESHOLD = .5;
  final float DEFAULT_FLOOR = .88;
  final float CLAP_MIN_FREQ = 2200;
  final float CLAP_MAX_FREQ = 2800;
  
  public L8onAudioClapGate(LX lx) {
    this("Clap", lx);
  }

  public L8onAudioClapGate(String label, LX lx) {
    this(label, lx.engine.audio.meter);
  }
  
  public L8onAudioClapGate(String label, GraphicMeter meter) {
    super(label, meter);        
    this.gain.setValue(DEFAULT_GAIN);
    this.threshold.setValue(DEFAULT_THRESHOLD);
    this.floor.setValue(DEFAULT_FLOOR);
    
    this.maxFreq.setValue(CLAP_MAX_FREQ);
    this.minFreq.setValue(CLAP_MIN_FREQ);
  }
  
  public L8onAudioClapGate(GraphicMeter meter, float minHz, float maxHz) {
    this("Clap", meter);
    setFrequencyRange(minHz, maxHz);
  }
  
  public L8onAudioClapGate(String label, GraphicMeter meter, int minHz, int maxHz) {
    this(label, meter);
    setFrequencyRange(minHz, maxHz);
  }  
}

public class Explosions extends LXPattern {
  // Used to store info about each explosion.
  // See L8onUtil.pde for the definition.
  private List<L8onExplosion> explosions = new ArrayList<L8onExplosion>();
  private final SinLFO saturationModulator = new SinLFO(80.0, 100.0, 200000);
  private BoundedParameter numExplosionsParameter = new BoundedParameter("NUM", 4.0, 1.0, 20.0);
  private BoundedParameter brightnessParameter = new BoundedParameter("BRGT", 50, 10, 80);
  
  private static final double GAIN_DEFAULT = 6;
  private static final double MODULATION_RANGE = 1;
  
  private BandGate audioModulatorFull;
  private CompoundParameter rateParameter = new CompoundParameter("RATE", 8000.0, 8000.0, 750.0);  
  
  private BoundedParameter blurParameter = new BoundedParameter("BLUR", 0.69);
  private L8onBlurLayer blurLayer = new L8onBlurLayer(lx, this, blurParameter);
  
  private Random pointRandom = new Random();
  
  private L8onAudioBeatGate beatGate = new L8onAudioBeatGate("XBEAT", lx);
  private L8onAudioClapGate clapGate = new L8onAudioClapGate("XCLAP", lx);

  public Explosions(LX lx) {
    super(lx);

    addParameter(numExplosionsParameter);
    addParameter(brightnessParameter);

    createAudioModulator();
    modulateRateParam();
    
    addParameter(rateParameter);    
    addParameter(blurParameter);

    addLayer(blurLayer);

    addModulator(saturationModulator).start();
    addModulator(beatGate).start();
    addModulator(clapGate).start();

    initExplosions();
  }
  
  private void createAudioModulator() {
    this.audioModulatorFull = new BandGate("Full", this.lx);
    addModulator(this.audioModulatorFull);
    this.audioModulatorFull.threshold.setValue(1);
    this.audioModulatorFull.floor.setValue(0);
    this.audioModulatorFull.gain.setValue(GAIN_DEFAULT);
    
    this.audioModulatorFull.maxFreq.setValue(this.audioModulatorFull.maxFreq.range.max);
    this.audioModulatorFull.minFreq.setValue(0);
    
    this.audioModulatorFull.start();
  }
  
  private void modulateRateParam() {
    LXCompoundModulation compoundModulation = new LXCompoundModulation(audioModulatorFull.average, rateParameter);    
    compoundModulation.range.setValue(MODULATION_RANGE); 
  }

  public void run(double deltaMs) {
    initExplosions();

    float base_hue = lx.palette.getHuef();
    float wave_hue_diff = (float) (360.0 / this.explosions.size());

    for(L8onExplosion explosion : this.explosions) {
      if (explosion.isChillin((float)deltaMs)) {
        continue;
      }
 
      explosion.hue_value = (float)(base_hue % 360.0);
      base_hue += wave_hue_diff;

      if (!explosion.hasExploded()) {
        explosion.explode();
      } else if (explosion.isFinished()) {
        assignNewCenter(explosion);
      }
    }

    color c;
    float hue_value = 0.0;
    float sat_value = saturationModulator.getValuef();
    float brightness_value = brightnessParameter.getValuef();    

    for (LXPoint p : model.points) {
      int num_explosions_in = 0;

      for(L8onExplosion explosion : this.explosions) {
        if(explosion.isChillin(0)) {
          continue;
        }

        if(explosion.onExplosion(p.x, p.y, p.z)) {
          num_explosions_in++;
          hue_value = L8onUtil.natural_hue_blend(explosion.hue_value, hue_value, num_explosions_in);
        }
      }

      if(num_explosions_in > 0) {
        c = LX.hsb(hue_value, sat_value, brightness_value);
      } else {
        c = colors[p.index];
        c = LX.hsb(LXColor.h(c), LXColor.s(c), 0.0);
      }

      colors[p.index] = c;
    }
  }

  private void initExplosions() {
    int num_explosions = (int) numExplosionsParameter.getValue();

    if (this.explosions.size() == num_explosions) {
      return;
    }

    if (this.explosions.size() < num_explosions) {
      for(int i = 0; i < (num_explosions - this.explosions.size()); i++) {
        float stroke_width = this.new_stroke_width();
        QuadraticEnvelope new_radius_env = new QuadraticEnvelope(0.0, model.xRange, rateParameter);
        new_radius_env.setEase(QuadraticEnvelope.Ease.OUT);
        LXPoint new_center_point = model.points[pointRandom.nextInt(model.points.length)];        
        addModulator(new_radius_env);
        BandGate explosionGate = (this.explosions.size() % 2 == 1) ? this.beatGate : this.clapGate;        
        this.explosions.add(
          new L8onExplosion(new_radius_env, explosionGate.gate, stroke_width, new_center_point.x, new_center_point.y, new_center_point.z)
        );
      }
    } else {
      for(int i = (this.explosions.size() - 1); i >= num_explosions; i--) {
        removeModulator(this.explosions.get(i).radius_modulator);
        this.explosions.remove(i);
      }
    }
  }

  private void assignNewCenter(L8onExplosion explosion) {
    float stroke_width = this.new_stroke_width();
    LXPoint new_center_point = model.points[pointRandom.nextInt(model.points.length)];
    float chill_time = (15.0 + random(15)) * 1000;
    QuadraticEnvelope new_radius_env = new QuadraticEnvelope(0.0, model.xRange, rateParameter);
    new_radius_env.setEase(QuadraticEnvelope.Ease.OUT);

    explosion.setCenter(new_center_point.x, new_center_point.y, new_center_point.z);
    addModulator(new_radius_env);
    explosion.setRadiusModulator(new_radius_env, stroke_width);
    explosion.setChillTime(chill_time);
  }

  public float new_stroke_width() {
    return 3 * INCHES + random(6 * INCHES);
  }
}

public class SunriseSunset extends LXPattern {
  BoundedParameter dayTime = new BoundedParameter("DAY", 24000, 10000, 240000);
  LXProjection projection = new LXProjection(model);  
  SawLFO sunPosition = new SawLFO(0, TWO_PI, dayTime);  
  
  CompoundParameter sunRadius = new CompoundParameter("RAD", 1, 1, 24);
  CompoundParameter colorSpread = new CompoundParameter("CLR", 0.65, 0.65, 1);
  
  private static final double GAIN_DEFAULT = 6;
  private static final double MODULATION_RANGE = 1;
  
  private BandGate audioModulatorLow;
  private BandGate audioModulatorMid;
  private BoundedParameter blurParameter = new BoundedParameter("BLUR", 0.69);
  private L8onBlurLayer blurLayer = new L8onBlurLayer(lx, this, blurParameter);
  
  private BoundedParameter yMinParam = new BoundedParameter("YMIN", 465, 400, model.yMax);
  
  public SunriseSunset(LX lx) {
    super(lx);
    addModulator(sunPosition).start();
    
    addParameter(blurParameter);
    addLayer(blurLayer);
    
    addParameter(dayTime);
    addParameter(yMinParam);
    addParameter(sunRadius);
    addParameter(colorSpread);
    
    this.createAudioModulators();
  }
   
  
  private void createAudioModulators() {    
    this.createLowAudioModulator();    
    this.createMidAudioModulator();
  }
  
  private void createLowAudioModulator() {
    this.audioModulatorLow = new BandGate("Low", this.lx);
    addModulator(this.audioModulatorLow);
    this.audioModulatorLow.threshold.setValue(1);
    this.audioModulatorLow.floor.setValue(0);
    this.audioModulatorLow.gain.setValue(GAIN_DEFAULT);
    
    this.audioModulatorLow.maxFreq.setValue(216);
    this.audioModulatorLow.minFreq.setValue(0);
    
    this.audioModulatorLow.start();
    
    LXCompoundModulation compoundModulationLow = new LXCompoundModulation(audioModulatorLow.average, sunRadius);
    compoundModulationLow.range.setValue(MODULATION_RANGE);
  }
  
  private void createMidAudioModulator() {
    this.audioModulatorMid = new BandGate("Mid", this.lx);
    addModulator(this.audioModulatorMid);
    this.audioModulatorMid.threshold.setValue(1);
    this.audioModulatorMid.floor.setValue(0);
    this.audioModulatorMid.gain.setValue(GAIN_DEFAULT);
    
    this.audioModulatorMid.maxFreq.setValue(2200);
    this.audioModulatorMid.minFreq.setValue(216);
    
    this.audioModulatorMid.start();
    
    LXCompoundModulation compoundModulationMid = new LXCompoundModulation(audioModulatorMid.average, colorSpread);
    compoundModulationMid.range.setValue(MODULATION_RANGE);
  }
  
  public void run(double deltaMs) {
    projection.reset();
    projection.rotateZ(sunPosition.getValuef());
    
    int i = 0;
    for(LXVector v: projection) {      
      if (model.yMax - v.y < sunRadius.getValuef()) {
          setColor(i, LX.hsb(0, 0, 100));
      } else if(v.y > yMinParam.getValuef()) {        
        float yn = (v.y - yMinParam.getValuef()) / model.yRange;        
        float hue = (350 + ((360 * colorSpread.getValuef() * yn))) % 360;
        setColor(i, LX.hsb(hue, 100, 100 * yn));  
      } else {
        setColor(i, 0);
      }
      i++;
    }
  }
}