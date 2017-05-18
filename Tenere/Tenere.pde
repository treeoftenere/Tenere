/**
 * Welcome to TÉNÉRÉ! Click the play button in the top left to give it a whirl.
 * The best place to get started with developing is a visit to the "Tutorial" tab.
 * There is code for an example pattern there, which gives some guidance.
 */
 
// Helpful global constants
final static float INCHES = 5;
final static float IN = INCHES;
final static float FEET = 12*INCHES;
final static float FT = FEET;
final static int _width = 1200;
final static int _height = 960;

// Our engine and our model
LXStudio lx;
Tree tree;
PApplet applet = Tenere.this;

// Global UI objects
UITreeStructure uiTreeStructure;
UILeaves uiLeaves;

// Processing's main invocation, build our model and set up LX
void setup() {
  size(1200, 960, P3D);
  final Timer t = new Timer();
  tree = buildTree();
  t.log("Built Tree Model");
  try {
    lx = new LXStudio(this, tree, false) {
      public void initialize(LXStudio lx, LXStudio.UI ui) {
        lx.registerEffect(BlurEffect.class);
        lx.registerEffect(DesaturationEffect.class);
        // TODO: the UDP output instantiation will go in here!
        t.log("Initialized LXStudio");
      }
      
      public void onUIReady(LXStudio lx, LXStudio.UI ui) {
        ui.preview.setRadius(50*FEET);
        ui.preview.addComponent(new UILogo());
        ui.preview.addComponent(new UITrunk());
        ui.preview.addComponent(uiTreeStructure = new UITreeStructure(tree));
        ui.preview.addComponent(uiLeaves = new UIShapeLeaves());

        ui.preview.pointCloud.setVisible(false);
        uiTreeStructure.setVisible(false);
        
        new UITreeControls(ui).addToContainer(ui.leftPane.global);
        t.log("Initialized LX UI");
      }
    };
  } catch (Exception x) {
    x.printStackTrace();
  }
}

void draw() {
  // LX handles everything for us!
}

void keyPressed() {
  // Little utility to get a bit of trace info from the engine
  if (key == 'z') {
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