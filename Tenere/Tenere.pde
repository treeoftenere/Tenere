/**
 * Welcome to TÉNÉRÉ! Click the play button in the top left to give it a whirl.
 * The best place to get started with developing is a visit to the "Tutorial" tab.
 * There is code for an example pattern there, which gives some guidance.
 */

// Change this line to specify the model mode!
Tree.ModelMode modelMode = Tree.ModelMode.MAJOR_LIMBS;
final static String STELLAR_FILE = "lastSleeExport.json";

// Helpful global constants
final static float INCHES = 5;
final static float IN = INCHES;
final static float FEET = 12*INCHES;
final static float FT = FEET;
final static float INCHES_PER_METER = 39.3701;
final static float METERS = INCHES_PER_METER * INCHES ;
final static float METERS_PER_INCH = 1 / INCHES_PER_METER;

// Static reference to applet
static PApplet applet;

// Our engine and our model
LXStudio lx;
Tree tree;
Sensors sensors;

// Global UI objects
UITreeStructure uiTreeStructure;
UILeaves uiLeaves;
UISensors uiSensors;

UITreeControls uiTreeControls;
UIOutputControls uiOutputControls;


//Muliple Muses
//each muse sends to a differnt port numbered sequentially starting with musePortOffset
Muse[] muse;
UIMuse[] uiMuse;
int num_muses = 3;
int musePortOffset=7810;

List<OPCDatagram> datagrams = new ArrayList<OPCDatagram>();

// Processing's main invocation, build our model and set up LX
void setup() {
  size(1200, 960, P3D);
  frameRate(60.1); // Weird hack, Windows box does 30 FPS when set to 60 for unclear reasons
  final Timer t = new Timer();
  applet = this;
  tree = buildTree();
  t.log("Built Tree Model");
  try {
    lx = new LXStudio(this, tree, false) {
      public void initialize(LXStudio lx, LXStudio.UI ui) {
        // Register a couple top-level effects
        lx.registerEffect(BlurEffect.class);
        //lx.registerEffect(DesaturationEffect.class);        

        // Register the settings component
        lx.engine.registerComponent("tenereSettings", new Settings(lx, ui));

        // Register the sensor integrations
        sensors = new Sensors(lx);
        lx.engine.registerComponent("sensors", sensors);
        lx.engine.addLoopTask(sensors);

        // Register a bunch of Muses
        muse = new Muse[num_muses];
        for (int k=0; k<num_muses;k=k+1){  
          muse[k] = new Muse(lx,musePortOffset+k);
          lx.engine.registerComponent("Muse"+k, muse[k]);
          lx.engine.addLoopTask(muse[k]);
        }
       
        // End-to-end test, sending one branch worth of data
        // 8 assemblages, 15 leaves, 7 leds = 840 points = 2,520 RGB bytes = 2,524 OPC bytes
        try {          

          // Update appropriately for testing!
          final String[] OPC_ADDRESS = new String[] {
            "192.168.1.2",
            "192.168.1.3",
            "192.168.1.4",
            "192.168.1.7",
            "192.168.1.9",
            "192.168.1.10",
            "192.168.1.11",
            "192.168.1.12",
          };
          final int OPC_PORT = 1337;

          int branchNum = 0;
          for (Branch branch : tree.branches) {
            int pointsPerPacket = branch.points.length / 2;
            int[] channels14 = new int[pointsPerPacket];
            int[] channels58 = new int[pointsPerPacket];
            for (int i = 0; i < pointsPerPacket; ++i) {
              channels14[i] = branch.points[i].index;
              channels58[i] = branch.points[i + pointsPerPacket].index;
            }

            datagrams.add((OPCDatagram) new TenereDatagram(lx, channels14, (byte) 0x00).setAddress(OPC_ADDRESS[branchNum]).setPort(OPC_PORT));
            datagrams.add((OPCDatagram) new TenereDatagram(lx, channels58, (byte) 0x04).setAddress(OPC_ADDRESS[branchNum]).setPort(OPC_PORT));
            
            // That's all we got...
            if (++branchNum >= OPC_ADDRESS.length) {
              break;
            }
          }

          // Create an LXDatagramOutput to own these packets
          LXDatagramOutput datagramOutput = new LXDatagramOutput(lx); 
          for (OPCDatagram datagram : datagrams) {
            datagramOutput.addDatagram(datagram);
          }

          // Add to the output
          lx.engine.output.addChild(datagramOutput);
          
        } catch (Exception x) {
          println("Failed to construct UDP output: " + x);
          x.printStackTrace();
        }

        t.log("Initialized LXStudio");
      }

      public void onUIReady(LXStudio lx, LXStudio.UI ui) {
        ui.preview.setRadius(80*FEET).setPhi(-PI/18).setTheta(PI/12);
        ui.preview.setCenter(0, model.cy - 2*FEET, 0);
        ui.preview.addComponent(new UISimulation());
        ui.preview.addComponent(uiLeaves = new UIShapeLeaves());
        ui.preview.pointCloud.setVisible(false);
        uiTreeStructure.setVisible(false);

        // Narrow angle lens, for a fuller visualization
        ui.preview.perspective.setValue(30);

        // Sensor integrations
        uiSensors = (UISensors) new UISensors(ui, ui.leftPane.global.getContentWidth()).addToContainer(ui.leftPane.global);
        
        //Add a UI for each Muse.
        uiMuse = new UIMuse[num_muses];
        for (int k=0; k<num_muses;k=k+1){  
           uiMuse[k] = (UIMuse) new UIMuse(ui, ui.leftPane.global.getContentWidth(),muse[k]).addToContainer(ui.leftPane.global);
        }
        // Custom tree rendering controls
        uiTreeControls = (UITreeControls) new UITreeControls(ui).setExpanded(false).addToContainer(ui.leftPane.global);
        uiOutputControls = (UIOutputControls) new UIOutputControls(ui).setExpanded(false).addToContainer(ui.leftPane.global);

        t.log("Initialized LX UI");
      }
    };
  } catch (Exception x) {
    println("Initialization error: " + x);
    x.printStackTrace();
  }

  // Use multi-threading for network output
  lx.engine.output.mode.setValue(LXOutput.Mode.RAW);
  lx.engine.setNetworkMultithreaded(true);
}

private class Settings extends LXComponent {

  private final LXStudio.UI ui;

  private Settings(LX lx, LXStudio.UI ui) {
    super(lx);
    this.ui = ui;
  }

  private static final String KEY_POINTS_VISIBLE = "pointsVisible";
  private static final String KEY_LEAVES_VISIBLE = "leavesVisible";
  private static final String KEY_STRUCTURE_VISIBLE = "structureVisible";
  private static final String KEY_CONTROLS_EXPANDED = "controlsExpanded";
  private static final String KEY_SENSORS_EXPANDED = "sensorsExpanded";
  private static final String KEY_MUSE_EXPANDED = "museExpanded";
  private static final String KEY_OUTPUT_EXPANDED = "outputExpanded";

  @Override
    public void save(LX lx, JsonObject obj) {
    obj.addProperty(KEY_POINTS_VISIBLE, this.ui.preview.pointCloud.isVisible());
    obj.addProperty(KEY_LEAVES_VISIBLE, uiLeaves.isVisible());
    obj.addProperty(KEY_STRUCTURE_VISIBLE, uiTreeStructure.isVisible());
    obj.addProperty(KEY_CONTROLS_EXPANDED, uiTreeControls.isExpanded());
    obj.addProperty(KEY_SENSORS_EXPANDED, uiSensors.isExpanded());
    obj.addProperty(KEY_OUTPUT_EXPANDED, uiOutputControls.isExpanded());
    for (int k=0; k<num_muses;k=k+1){  
      obj.addProperty(KEY_MUSE_EXPANDED+k, uiMuse[k].isExpanded());
    }
  }

  @Override
    public void load(LX lx, JsonObject obj) {
    if (obj.has(KEY_POINTS_VISIBLE)) {
      uiTreeControls.pointsVisible.setActive(obj.get(KEY_POINTS_VISIBLE).getAsBoolean());
    }
    if (obj.has(KEY_LEAVES_VISIBLE)) {
      uiTreeControls.leavesVisible.setActive(obj.get(KEY_LEAVES_VISIBLE).getAsBoolean());
    }
    if (obj.has(KEY_STRUCTURE_VISIBLE)) {
      uiTreeControls.structureVisible.setActive(obj.get(KEY_STRUCTURE_VISIBLE).getAsBoolean());
    }
    if (obj.has(KEY_CONTROLS_EXPANDED)) {
      uiTreeControls.setExpanded(obj.get(KEY_CONTROLS_EXPANDED).getAsBoolean());
    }
    if (obj.has(KEY_SENSORS_EXPANDED)) {
      uiSensors.setExpanded(obj.get(KEY_SENSORS_EXPANDED).getAsBoolean());
    }
    if (obj.has(KEY_OUTPUT_EXPANDED)) {
      uiOutputControls.setExpanded(obj.get(KEY_OUTPUT_EXPANDED).getAsBoolean());
    }
    for (int k=0; k<num_muses;k=k+1){
      if (obj.has(KEY_MUSE_EXPANDED+k)) {
        uiMuse[k].setExpanded(obj.get(KEY_MUSE_EXPANDED+k).getAsBoolean());
      }
    }
  }
}

void draw() {
  // LX handles everything for us!
}

void keyPressed(KeyEvent keyEvent) {
  if (key == 'z') {
    // Little utility to get a bit of trace info from the engine
    lx.engine.logTimers();
  }
}

private class Timer {
  private long last;

  Timer() {
    this.last = millis();
  }

  void log(String event) {
    long now = millis();
    println(event + ": " + (now - last) + "ms");
    this.last = now;
  }
}