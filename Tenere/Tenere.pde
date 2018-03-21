/**
 * Welcome to TÉNÉRÉ! Click the play button in the top left to give it a whirl.
 * The best place to get started with developing is a visit to the "Tutorial" tab.
 * There is code for an example pattern there, which gives some guidance.
 */

// Choose one of these line to specify the model mode!
Tree.ModelMode modelMode = Tree.ModelMode.MAJOR_LIMBS;
// Tree.ModelMode modelMode = Tree.ModelMode.STELLAR_IMPORT;
final static String STELLAR_FILE = "TenereExportTestMondayWithID.json";

// Special board testing mode
final static boolean BOARD_TEST_MODE = false;
final static boolean SUBNET_TEST_MODE = false;
final static boolean SINGLE_BRANCH_MODE = false;

final static boolean READ_PINGSCAN = false;

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
UISources uiSources;

UITreeControls uiTreeControls;
UIOutputControls uiOutputControls;

List<TenereDatagram> datagrams = new ArrayList<TenereDatagram>();

DiscreteParameter boardNumber = (DiscreteParameter)
  new DiscreteParameter("BoardNumber", 1, 1, 256)
  .setUnits(LXParameter.Units.INTEGER);

// Processing's main invocation, build our model and set up LX
void setup() {
  size(1200, 960, P3D);
  final Timer t = new Timer();
  applet = this;
  tree = buildTree();
  t.log("Built Tree Model");
  try {
    lx = new LXStudio(this, tree, true) {
      public void initialize(LXStudio lx, LXStudio.UI ui) {
        // Register a couple top-level effects
        lx.registerEffect(BlurEffect.class);
        lx.registerEffect(StrobeEffect.class);        

        // Register the settings component
        lx.engine.registerComponent("tenereSettings", new Settings(lx, ui));

        // Register the sensor integrations
        sensors = new Sensors(lx);
        lx.engine.registerComponent("sensors", sensors);
        lx.engine.addLoopTask(sensors);
       
        // End-to-end test, sending one branch worth of data
        // 8 assemblages, 15 leaves, 7 leds = 840 points = 2,520 RGB bytes = 2,524 OPC bytes
        try {          

          // Update appropriately for testing!
          final int OPC_PORT = 1337;
          final String[] OPC_ADDRESS;
          
          final String[] COMPARE;
          final String[] SUBNET_TEST;
          
          if (SUBNET_TEST_MODE) {
            println("FULL SUBNET TEST MODE: Outputing sequentially to all IP addresses 192.168.1.1-192.168.1.240");
            OPC_ADDRESS = new String[240];
            for (int i = 0; i < OPC_ADDRESS.length; ++i) {
              OPC_ADDRESS[i] = String.format("192.168.1.%d", i);
            }
          }
          
          // reads in output from pingscan
         else if (READ_PINGSCAN) {
           String[] lines = loadStrings("addresses.txt");
           println("there are " + lines.length + " controllers alive");

           // populate targets
           OPC_ADDRESS = new String[lines.length];
           for (int i = 0; i < lines.length; i++) {
             println(lines[i]);
             OPC_ADDRESS[i] = String.format("%s", lines[i]);
           }
         } else {
           OPC_ADDRESS = new String[] {
// THE CURRENT ADDRESSES RESPONDING IN THE TREE
// "10.200.1.64"
"10.200.1.77",
"10.200.1.78",
// "192.168.1.2",        
// "192.168.1.10",       
// "192.168.1.12",       
// "192.168.1.15",       
// "192.168.1.17",       
// "192.168.1.18",       
// "192.168.1.19",       
// "192.168.1.20",       
// "192.168.1.21",       
// "192.168.1.23",       
// "192.168.1.24",       
// "192.168.1.25",       
// "192.168.1.26",       
// "192.168.1.27",       
// "192.168.1.28",       
// "192.168.1.29",       
// "192.168.1.11",       
// "192.168.1.31",       
// "192.168.1.39",       
// "192.168.1.40",       
// "192.168.1.43",       
// "192.168.1.44",       
// "192.168.1.45",       
// "192.168.1.64",       
// "192.168.1.65",       
// "192.168.1.66",       
// "192.168.1.67",       
// "192.168.1.68",       
// "192.168.1.69",       
// "192.168.1.70",       
// "192.168.1.73",       
// "192.168.1.74",       
// "192.168.1.76",       
// "192.168.1.77",       
// "192.168.1.84",       
// "192.168.1.85",       
// "192.168.1.86",       
// "192.168.1.88",       
// "192.168.1.90",       
// "192.168.1.94",       
// "192.168.1.97",       
// "192.168.1.98",       
// "192.168.1.99",       
// "192.168.1.101",      
// "192.168.1.106",      
// "192.168.1.111",      
// "192.168.1.113",      
// "192.168.1.114",      
// "192.168.1.116",      
// "192.168.1.117",      
// "192.168.1.120",      
// "192.168.1.121",      
// "192.168.1.125",      
// "192.168.1.126",      
// "192.168.1.128",      
// "192.168.1.129",      
// "192.168.1.131",      
// "192.168.1.132",      
// "192.168.1.134",      
// "192.168.1.135",      
// "192.168.1.141",      
// "192.168.1.142",      
// "192.168.1.143",      
// "192.168.1.144",      
// "192.168.1.152",      
// "192.168.1.159",      
// "192.168.1.163",      
// "192.168.1.166",      
// "192.168.1.168",      
// "192.168.1.175",      
// "192.168.1.177",      
// "192.168.1.183",      
// "192.168.1.190",      
// "192.168.1.191",      
// "192.168.1.195",      
// "192.168.1.240",      
           };
         }
         println(OPC_ADDRESS);
          
          // NOTE: the leaves aren't ordered exactly sequentially, this fixes that
          final int[] LEAF_ORDER = {
            0, 1, 3, 5, 2, 4, 6, 7, 8, 10, 12, 9, 11, 13, 14
          };
          int branchNum = 0;
          
          for (Branch branch : tree.branches) {
            int pointsPerPacket = Branch.NUM_LEDS / 2;
            int[] channels14 = new int[pointsPerPacket];
            int[] channels58 = new int[pointsPerPacket];
            for (int i = 0; i < pointsPerPacket; ++i) {
              // Initialize to nothing
              channels14[i] = channels58[i] = -1;
            }
            for (LeafAssemblage assemblage : branch.assemblages) {
              int[] buffer = (assemblage.channel < 4) ? channels14 : channels58;
              int pi = (assemblage.channel % 4) * LeafAssemblage.NUM_LEDS;
              for (int li : LEAF_ORDER) {
                Leaf leaf = assemblage.leaves.get(li);
                for (LXPoint p : leaf.points) {
                  buffer[pi++] = p.index;
                }
              }
            }
            
            // IP address is either specified from stellar mapping, or we use the
            // manual list above...
            String ip = branch.ip;
            if (ip == null) {
              ip = OPC_ADDRESS[branchNum++];
            }
            // Use manual IP in board test mode 
            if (BOARD_TEST_MODE) {
              ip = "192.168.1." + boardNumber.getValuei();
            }

            // Add the datagrams
            datagrams.add((TenereDatagram) new TenereDatagram(lx, channels14, (byte) 0x00).setAddress(ip).setPort(OPC_PORT));
            datagrams.add((TenereDatagram) new TenereDatagram(lx, channels58, (byte) 0x04).setAddress(ip).setPort(OPC_PORT));
                        
            // Are we out of manual addresses?
            if (branchNum >= OPC_ADDRESS.length) {
              if (SUBNET_TEST_MODE) {
                // Just keep outputting the last branch!
                --branchNum;
              } else {
                break;
              }
            }
            
            // Only one set of datagrams if in board test mode! We're testing a single IP in that case
            if (BOARD_TEST_MODE) {
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

        if (BOARD_TEST_MODE) {
          boardNumber.addListener(new LXParameterListener() {
            public void onParameterChanged(LXParameter p) {
              for (LXDatagram datagram : datagrams) {
                try {
                  datagram.setAddress("192.168.1." + boardNumber.getValuei());
                } catch (Exception x) {
                  println("BAD ADDRESS: " + x.getLocalizedMessage());
                  x.printStackTrace();
                  exit();
                }
              }
            }
          });
        }

        t.log("Initialized LXStudio");
      }

      public void onUIReady(LXStudio lx, LXStudio.UI ui) {
        ui.leftPane.engine.setVisible(true);
        
        ui.preview.setRadius(80*FEET).setPhi(-PI/18).setTheta(PI/12);
        ui.preview.setCenter(0, model.cy - 2*FEET, 0);
        ui.preview.addComponent(new UISimulation());
        ui.preview.addComponent(uiLeaves = new UIShapeLeaves());
        ui.preview.pointCloud.setVisible(false);
        uiTreeStructure.setVisible(false);

        // Narrow angle lens, for a fuller visualization
        ui.preview.perspective.setValue(30);

        // Sensor integrations
        uiSensors = (UISensors) new UISensors(ui, sensors, ui.leftPane.global.getContentWidth()).addToContainer(ui.leftPane.global);  
        uiSources = (UISources) new UISources(ui, sensors, ui.leftPane.global.getContentWidth()).addToContainer(ui.leftPane.global);
        
        // Custom tree rendering controls
        uiTreeControls = (UITreeControls) new UITreeControls(ui).setExpanded(false).addToContainer(ui.leftPane.global);
        uiOutputControls = (UIOutputControls) new UIOutputControls(ui).setExpanded(false).addToContainer(ui.leftPane.global);

        // Board testing mode
        if (BOARD_TEST_MODE) {
          new UIBoardTest(ui, lx).setExpanded(true).addToContainer(ui.leftPane.global);
        }

        t.log("Initialized LX UI");
      }
    };
  } catch (Exception x) {
    println("Initialization error: " + x);
    x.printStackTrace();
  }

  // Use multi-threading for network output
  lx.engine.output.mode.setValue(LXOutput.Mode.RAW);
  
  frameRate(60.1); // Weird hack, Windows box does 30 FPS when set to 60 for unclear reasons
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
  private static final String KEY_SOURCES_EXPANDED = "sourcesExpanded";
  private static final String KEY_OUTPUT_EXPANDED = "outputExpanded";

  @Override
    public void save(LX lx, JsonObject obj) {
    obj.addProperty(KEY_POINTS_VISIBLE, this.ui.preview.pointCloud.isVisible());
    obj.addProperty(KEY_LEAVES_VISIBLE, uiLeaves.isVisible());
    obj.addProperty(KEY_STRUCTURE_VISIBLE, uiTreeStructure.isVisible());
    obj.addProperty(KEY_CONTROLS_EXPANDED, uiTreeControls.isExpanded());
    obj.addProperty(KEY_SENSORS_EXPANDED, uiSensors.isExpanded());
    obj.addProperty(KEY_SOURCES_EXPANDED, uiSources.isExpanded());
    obj.addProperty(KEY_OUTPUT_EXPANDED, uiOutputControls.isExpanded());
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
    if (obj.has(KEY_SOURCES_EXPANDED)) {
      uiSources.setExpanded(obj.get(KEY_SOURCES_EXPANDED).getAsBoolean());
    }
    if (obj.has(KEY_OUTPUT_EXPANDED)) {
      uiOutputControls.setExpanded(obj.get(KEY_OUTPUT_EXPANDED).getAsBoolean());
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