/**
 * This Tenere-specific component takes input from sensors via OSC messages and
 * exposes them to the UI as LX parameters.
 */
public class Sensors extends LXModulatorComponent implements LXOscListener {

  public static final int OSC_PORT = 7878;

  public final BoundedParameter heartRate = (BoundedParameter)
    new BoundedParameter("Heart Rate", 80, 0, 200)
    .setDescription("Measurement received from heart rate sensor");

  public final LinearEnvelope heartBeat = (LinearEnvelope) new LinearEnvelope("Heart Beat", 1, 0, new FunctionalParameter() {
    public double getValue() {
      return 60000 / heartRate.getValue();
    }
  }
  )
  .setDescription("Indication of heart beat cycle");



  public final LinearEnvelope commandPattern = (LinearEnvelope) new LinearEnvelope("Pattern", 1, 0, new FunctionalParameter() {
    public double getValue() {
      return 60000 / 80;
    }
  }
  )
  .setDescription("Indication of PATTERN voice command");

  public final LinearEnvelope commandMeditation = (LinearEnvelope) new LinearEnvelope("Meditation", 1, 0, new FunctionalParameter() {
    public double getValue() {
      return 60000 / 80;
    }
  }
  )
  .setDescription("Indication of MEDITATION voice command");


  public final BoundedParameter muse = (BoundedParameter) new BoundedParameter("Muse", 0, 0, 1600)
    .setDescription("Brain wave input from the Muse network");

  public Sensors(LX lx) {
    super(lx, "Sensors");
    addParameter("heartRate", this.heartRate);
    addParameter("muse", this.muse);

    this.heartBeat.setValue(0);
    addModulator(this.heartBeat);


    this.commandPattern.setValue(0);
    addModulator(this.commandPattern);
    this.commandMeditation.setValue(0);
    addModulator(this.commandMeditation);


    // Register for custom OSC messages on a dedicated port
    try {
      lx.engine.osc.receiver(OSC_PORT).addListener(this);
    } 
    catch (java.net.SocketException sx) {
      throw new RuntimeException(sx);
    }
  }

  /**
   * This method handles OSC message dispatch for the specific sensor listeners. 
   */
  public void oscMessage(OscMessage message) {
    if (message.matches("/grove/pulsesensor")) {
      if (message.getFloat() > 800) {
        this.heartBeat.trigger();
        //println("Heartbeat triggered!!!!    " + message.getFloat());
      }
    } else if (message.matches("/grove/analog")) {
      //println("Analog0" + message.getFloat(0) + "Analog1" + message.getFloat(1) + "Analog2" + message.getFloat(2));
    } else if (message.matches("/grove/digital")) {
      //println("Digital3" + message.getFloat(0));
    } else if (message.matches("/grove/accel")) {
      //println("Accelerometer (x,y,z)" + message.getFloat(0) + " " + message.getFloat(2) + " " + message.getFloat(2));
    } else if (message.matches("/voice/command")) {

      //XXX What is a better way to trigger a pattern?
      //println("voice command: " + message); 
      if (message.getString().matches("Pattern")) {      
        this.commandPattern.trigger();
      } else if (message.getString().matches("Meditation")) {     
        this.commandMeditation.trigger();
      }
    } else if (message.matches("/muse/eeg")) {
      //println(message.getFloat(0) + " " + message.getFloat(1) + " " + message.getFloat(2) + " " + message.getFloat(3)  + " " + message.getFloat(4));
    } else if (message.matches("/muse/gyro")) {
      //println(message.getFloat(0) + " " + message.getFloat(1) + " " + message.getFloat(2) + " " + message.getFloat(3)  + " " + message.getFloat(4));
    } else if (message.matches("/muse/acc")) {
      //println(message.getFloat(0) + " " + message.getFloat(1) + " " + message.getFloat(2) + " " + message.getFloat(3)  + " " + message.getFloat(4));
    } else {
      println("Unrecognized sensor OSC message: " + message.getAddressPattern());
    }
  }
}