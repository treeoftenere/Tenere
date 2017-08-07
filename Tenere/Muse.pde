/**
 * This Tenere-specific component takes input from Muse via OSC messages and
 * exposes them to the UI as LX parameters.
 */
public class Muse extends LXModulatorComponent implements LXOscListener {

  public int OSC_PORT;
  
  //to rescale Muse inputs to be 0 - 1
  public float eegOffset = 0;
  public float eegScale = 1600;
  public float accOffset = 0.5;
  public float accScale = 500;
  public float gyroOffset = 0.5;
  public float gyroScale = 500;
  
  public final BoundedParameter eeg0 = (BoundedParameter) new BoundedParameter("eegBL", 0, 0, 1)
    .setDescription("Brain wave input from the Muse Back Left");
  public final BoundedParameter eeg1 = (BoundedParameter) new BoundedParameter("eegFL", 0,  0, 1)
    .setDescription("Brain wave input from the Muse Back Left");
  public final BoundedParameter eeg2 = (BoundedParameter) new BoundedParameter("eegFR", 0,  0, 1)
    .setDescription("Brain wave input from the Muse Front Right");
  public final BoundedParameter eeg3 = (BoundedParameter) new BoundedParameter("eegBR", 0,  0, 1)
    .setDescription("Brain wave input from the Muse Back Right");

  public final BoundedParameter acc0 = (BoundedParameter) new BoundedParameter("acc0", 0,  0, 1)
    .setDescription("Acc input from Muse, axis 0");
  public final BoundedParameter acc1 = (BoundedParameter) new BoundedParameter("acc1", 0, 0, 1)
    .setDescription("Acc input from Muse, axis 1");
  public final BoundedParameter acc2 = (BoundedParameter) new BoundedParameter("acc2", 0, 0, 1)
    .setDescription("Acc input from Muse, axis 2");
    
   public final BoundedParameter gyro0 = (BoundedParameter) new BoundedParameter("gyro0", 0, 0, 1)
    .setDescription("Gyro input from Muse, axis 0");
   public final BoundedParameter gyro1 = (BoundedParameter) new BoundedParameter("gyro1", 0,  0, 1)
    .setDescription("Gyro input from Muse, axis 1");
   public final BoundedParameter gyro2 = (BoundedParameter) new BoundedParameter("gyro2", 0,  0, 1)
    .setDescription("Gyro input from Muse, axis 1");
 
  public Muse(LX lx, int osc_port) {
    super(lx, "Muse");
   
    addParameter("eegBL", this.eeg0);
    addParameter("eegFL", this.eeg1);
    addParameter("eegFR", this.eeg2);
    addParameter("eegBR", this.eeg3);
    addParameter("acc0", this.acc0);
    addParameter("acc1", this.acc1);
    addParameter("acc2", this.acc2);
    addParameter("gyro0", this.gyro0);
    addParameter("gyro1", this.gyro1);
    addParameter("gyro2", this.gyro2);

    OSC_PORT=osc_port;
    try {
      lx.engine.osc.receiver(OSC_PORT).addListener(this);
    } 
    catch (java.net.SocketException sx) {
      throw new RuntimeException(sx);
    }

  }

  /**
   * This method handles OSC message dispatch for the specific Muse
   * https://github.com/treeoftenere/Interactivity
   */
  public void oscMessage(OscMessage message) {
    if (message.matches("/muse/eeg")) {
      //println(message.getFloat(0) + " " + message.getFloat(1) + " " + message.getFloat(2) + " " + message.getFloat(3)  + " " + message.getFloat(4))
        this.eeg0.setValue(message.getFloat(0)/eegScale+eegOffset);
        this.eeg1.setValue(message.getFloat(1)/eegScale+eegOffset); //<>//
        this.eeg2.setValue(message.getFloat(2)/eegScale+eegOffset);
        this.eeg3.setValue(message.getFloat(3)/eegScale+eegOffset);
    } else if (message.matches("/muse/gyro")) {
      //println(message.getFloat(0) + " " + message.getFloat(1) + " " + message.getFloat(2));
        this.gyro0.setValue(message.getFloat(0)/gyroScale+gyroOffset);
        this.gyro1.setValue(message.getFloat(1)/gyroScale+gyroOffset);
        this.gyro2.setValue(message.getFloat(2)/gyroScale+gyroOffset);
    } else if (message.matches("/muse/acc")) {
      //println(message.getFloat(0) + " " + message.getFloat(1) + " " + message.getFloat(2));
        this.acc0.setValue(message.getFloat(0)/accScale+accOffset);
        this.acc1.setValue(message.getFloat(1)/accScale+accOffset);
        this.acc2.setValue(message.getFloat(2)/accScale+accOffset);
    } else {
      println("Unrecognized sensor OSC message: " + message.getAddressPattern());
    }
  }
}