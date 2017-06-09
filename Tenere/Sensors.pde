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
  })
  .setDescription("Indication of heart beat cycle");
  
  public final BoundedParameter muse = (BoundedParameter) new BoundedParameter("Muse", 0)
    .setDescription("Brain wave input from the Muse network");
  
  public Sensors(LX lx) {
    super(lx, "Sensors");
    addParameter("heartRate", this.heartRate);
    addParameter("muse", this.muse);
    
    this.heartBeat.setValue(0);
    addModulator(this.heartBeat);
    
    // Register for custom OSC messages on a dedicated port
    try {
      lx.engine.osc.receiver(OSC_PORT).addListener(this);
    } catch (java.net.SocketException sx) {
      throw new RuntimeException(sx);
    }    
  }
  
  /**
   * This method handles OSC message dispatch for the specific sensor listeners. 
   */
  public void oscMessage(OscMessage message) {
    if (message.matches("/heart/beat")) {
      this.heartBeat.trigger();
    } else if (message.matches("/heart/rate")) {
      this.heartRate.setValue(message.getFloat());
    } else if (message.matches("/muse")) {
      this.muse.setValue(message.getFloat());
    } else {
      println("Unrecognized sensor OSC message: " + message.getAddressPattern());
    }
  }
}