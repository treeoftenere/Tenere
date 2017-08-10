/**
 * This Tenere-specific component takes input from sensors via OSC messages and
 * exposes them to the UI as LX parameters.
 */
public class Sensors extends LXModulatorComponent implements LXOscListener {

  private static final int NUM_MUSES = 3;
  private static final int MUSE_BASE_PORT = 7810;
  
  private static final int NUM_TENERE_PIS = 10;
  
  private static final int OSC_PORT = 7878;
  
  private static final int NUM_VIRTUAL_SENSORS = 5;
  public final String[] SENSOR_LABELS = { "A", "B", "C", "D", "E" }; 

  private final LX lx;
  public final Sensor[] sensor = new Sensor[NUM_VIRTUAL_SENSORS];
  private final Map<String, Source> prefixToSource = new HashMap<String, Source>();
  private final List<Source> sources = new ArrayList<Source>(); 

  public Sensors(LX lx) {
    super(lx, "Sensors");
    this.lx = lx;
    sources.add(new Source());
    for (int i = 0; i < NUM_VIRTUAL_SENSORS; ++i) {
      addSubcomponent(sensor[i] = new Sensor(lx, SENSOR_LABELS[i]));
    }
    for (int i = 0; i < NUM_MUSES; ++i) {
      registerSourcePort(MUSE_BASE_PORT + i);
    }
    for (int i = 0; i < NUM_TENERE_PIS; ++i) {
      registerSourcePrefix(String.format("tp%02d", i));
    }
    
    try {
      // Register for custom OSC messages on a dedicated port
      lx.engine.osc.receiver(OSC_PORT).addListener(this);
    } catch (java.net.SocketException sx) {
      throw new RuntimeException(sx);
    }
  }
    
  public void registerSourcePrefix(String prefix) {
    Source source = new Source(prefix);
    this.prefixToSource.put(prefix, source);
    registerSource(source);
  }
  
  public void registerSourcePort(int port) {
    registerSource(new Source(port));
  }
  
  private void registerSource(Source source) {
    this.sources.add(source);
    Source[] sourceObjects = this.sources.toArray(new Source[] {});
    for (Sensor sensor : this.sensor) {
      sensor.source.setObjects(sourceObjects);
    }
  }
  
  @Override
  public void loop(double deltaMs) {
    super.loop(deltaMs);
    for (Sensor sensor : this.sensor) {
      sensor.loop(deltaMs);
    }
    for (Source source : this.sources) {
      if (source != null) {
        source.loop(deltaMs);
      }
    }
  }

  class Input implements LXLoopTask {
        
    public final BooleanParameter heartBeat = new BooleanParameter("Heart Beat").setDescription("Heart Beat trigger from the pulse sensor");
    public final LinearEnvelope heartLevel = (LinearEnvelope) new LinearEnvelope("Heart Beat", 0, 0, 500).setDescription("Heart beat indicator");
    
    public final NormalizedParameter[] eeg = new NormalizedParameter[] {
      new NormalizedParameter("EEG BL", 0).setDescription("Brain wave input from the Muse Back Left"),
      new NormalizedParameter("EEG FL", 0).setDescription("Brain wave input from the Muse Front Left"),
      new NormalizedParameter("EEG FR", 0).setDescription("Brain wave input from the Muse Front Right"),
      new NormalizedParameter("EEG BR", 0).setDescription("Brain wave input from the Muse Back Right"),
    };
    
    public final NormalizedParameter[] acc = new NormalizedParameter[] {
      new NormalizedParameter("Acc 0", 0).setDescription("Accelerometer input from Muse axis 0"),
      new NormalizedParameter("Acc 1", 0).setDescription("Accelerometer input from Muse axis 1"),
      new NormalizedParameter("Acc 2", 0).setDescription("Accelerometer input from Muse axis 2"),
    };
    
    public final NormalizedParameter[] gyro = new NormalizedParameter[] {
      new NormalizedParameter("Gyro 0", 0).setDescription("Gyro input from Muse axis 0"),
      new NormalizedParameter("Gyro 1", 0).setDescription("Gyro input from Muse axis 1"),
      new NormalizedParameter("Gyro 2", 0).setDescription("Gyro input from Muse axis 2"),
    };
    
    public final static int HEART = 0;
    public final static int EEG = 1;
    public final static int ACC = 2;
    public final static int GYRO = 3;
    
    private final Object[] fields = { heartBeat, eeg, acc, gyro };
    
    protected Input() {
      this.heartBeat.addListener(new LXParameterListener() {
        public void onParameterChanged(LXParameter p) {
          heartLevel.setRange(1, 0).trigger();
          heartBeat.setValue(false);
        }
      });
    }
    
    void set(int field, OscMessage message) {
      set(field, message, 0, 0);
    }
    
    /**
     * Sets the value of a field in the input table. The field parameter is one
     * of the constants defined above.
     */
    void set(int field, OscMessage message, float scale, float offset) {
      Object obj = this.fields[field];
      if (obj instanceof NormalizedParameter[]) {
        NormalizedParameter[] arr = (NormalizedParameter[]) obj; 
        for (int i = 0; i < arr.length; ++i) {
          arr[i].setValue(message.getFloat(i) / scale + offset); 
        }
      } else if (obj instanceof BooleanParameter) {
        ((BooleanParameter) obj).setValue(true);
      }
    }
    
    /**
     * Copies over all the parameter fields from another input. This is useful when
     * a sensor is mapped to a new source.
     */
    void set(Input that) {
      for (int i = 0; i < this.fields.length; ++i) {
        Object field = this.fields[i];
        if (field instanceof NormalizedParameter[]) {
          NormalizedParameter[] thisArr = (NormalizedParameter[]) field;
          NormalizedParameter[] thatArr = (NormalizedParameter[]) that.fields[i];
          for (int a = 0; a < thisArr.length; ++a) {
            thisArr[a].setValue(thatArr[a].getValue());
          }
        }
      }
    }
    
    public void loop(double deltaMs) {
      this.heartLevel.loop(deltaMs);
    }
  }

  public class Source extends Input implements LXOscListener {
    
    final boolean isNull;
    final String label;
    
    Source() {
      this.label = "No Input";
      this.isNull = true;
    }
    
    Source(String prefix) {
      this.label = "/" + prefix;
      this.isNull = false;
    }
    
    Source(int port) {
      this.label = "Port " + port;
      this.isNull = false;
      try {
        // Register for OSC messages on a dedicated port
        lx.engine.osc.receiver(port).addListener(this);
      } catch (java.net.SocketException sx) {
        throw new RuntimeException(sx);
      }
    }
    
    public String toString() {
      return this.label;
    }
    
    void set(int field, OscMessage message, float scale, float offset) {
      super.set(field, message, scale, offset);
      for (Sensor s : sensor) {
        if (s.enabled.isOn() && s.getSource() == this) {
          s.input.set(field, message, scale, offset);
        }
      }
    }
    
    public void oscMessage(OscMessage message) {
      // This callback is specific to the registered port, dispatch it
      oscSourceMessage(this, message);
    }
    
  }
  
  public class Sensor extends LXModulatorComponent {
    
    public final Input input = new Input();
    
    public final BooleanParameter heartBeat = input.heartBeat;
    public final LinearEnvelope heartLevel = input.heartLevel;
    public final NormalizedParameter[] eeg = input.eeg;
    public final NormalizedParameter[] acc = input.acc;
    public final NormalizedParameter[] gyro = input.gyro;
    
    public final BooleanParameter enabled = new BooleanParameter("Enabled", true)
      .setDescription("Whether the sensor is enabled");
    
    public final DiscreteParameter source = new DiscreteParameter("Source", sources.toArray(new Source[]{}))
      .setDescription("Which source input this sensor uses");  

    public Sensor(LX lx, String label) {
      super(lx, label);
      addParameter("enabled", this.enabled);
      addParameter("source", this.source);
      addParameter("heartBeat", this.heartBeat);
      addModulator(this.heartLevel);
      for (int i = 0; i < this.eeg.length; ++i) {
        addParameter("eeg" + i, this.eeg[i]);
      }
      for (int i = 0; i < this.acc.length; ++i) {
        addParameter("acc" + i, this.acc[i]);
      }
      for (int i = 0; i < this.gyro.length; ++i) {
        addParameter("gyro" + i, this.gyro[i]);
      }
    }
    
    public void onParameterChanged(LXParameter p) {
      if (p == this.source) {
        if (this.enabled.isOn()) {
          this.input.set(getSource());
        }
      }
    }
    
    public Source getSource() {
      return (Source) source.getObject();
    }
  }

  private static final float EEG_OFFSET = 0;
  private static final float EEG_SCALE = 1600;
  private static final float ACC_OFFSET = 0.5;
  private static final float ACC_SCALE = 500;
  private static final float GYRO_OFFSET = 0.5;
  private static final float GYRO_SCALE = 500;

  public void oscMessage(OscMessage message) {
    String addressPattern = message.getAddressPattern().getValue();
    String[] path = addressPattern.split("/");
    if (path.length >= 1) {
      Source source = prefixToSource.get(path[1]);
      if (source != null) {
        oscSourceMessage(source, message, addressPattern.substring(path[1].length() + 1));
        return;
      }
    }
    println("Unrecognized sensor OSC message: " + message.getAddressPattern());
  }

  /**
   * This method handles OSC message dispatch for the specific sensor listeners. 
   *
   * The grove channels are specific to the Raspberry Pi (TenerePi).  See more at:
   * https://github.com/treeoftenere/Interactivity
   */
  public void oscSourceMessage(Source source, OscMessage message) {
    oscSourceMessage(source, message, message.getAddressPattern().getValue());
  }
  
  /**
   * Processes an OSC message coming from the given source, with the given path
   */ 
  public void oscSourceMessage(Source source, OscMessage message, String path) {
    if (path.equals("/muse/eeg")) {
      source.set(Input.EEG, message, EEG_SCALE, EEG_OFFSET);
    } else if (path.equals("/muse/gyro")) {
      source.set(Input.GYRO, message, GYRO_SCALE, GYRO_OFFSET);
    } else if (path.equals("/muse/acc")) {
      source.set(Input.ACC, message, ACC_SCALE, ACC_OFFSET);
    } else if (path.equals("/grove/pulsesensor")) {
      if (message.getFloat(0) > 800) {
        // println("Heartbeat triggered!!!!    " + message.getFloat(0));
        source.set(Input.HEART, message);
      }
    } else if (path.equals("/grove/analog")) {
      //println("Analog0: " + message.getFloat(0) + "  Analog1: " + message.getFloat(1) + "  Analog2: " + message.getFloat(2));
    } else if (path.equals("/grove/digital")) {
      //println("Digital3: " + message.getInt(0));
    } else if (path.equals("/grove/accel")) {
      //println("Accelerometer (x,y,z): " + message.getFloat(0) + "  " + message.getFloat(1) + "  " + message.getFloat(2));
    } else if (path.equals("/voice/command")) {
      //XXX What is a better way to trigger a pattern?
      println("Voice command: " + message); 
      if (message.getString().matches("Pattern")) {      
        // TODO: call lx.engine.getChannel(index).goIndex(patternIndex);
      } else if (message.getString().matches("Meditation")) {     
        // TODO: invoke the meditation pattern
      }
    } else {
      println("Unrecognized sensor OSC message from " + source + ": " + message.getAddressPattern());
    }
  }
  
  private static final String KEY_SENSORS = "sensors";
  
  @Override
  public void save(LX lx, JsonObject obj) {
    super.save(lx, obj);
    obj.add(KEY_SENSORS, LXSerializable.Utils.toArray(lx, this.sensor));
  }
  
  @Override
  public void load(LX lx, JsonObject obj) {
    super.load(lx, obj);
    if (obj.has(KEY_SENSORS)) {
      int i = 0;
      JsonArray sensorArray = obj.getAsJsonArray(KEY_SENSORS);
      for (JsonElement sensorObj : sensorArray) {
        this.sensor[i++].load(lx, (JsonObject) sensorObj);
      }
    }
  }
}