import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import processing.opengl.PGraphics2D;

public class FrameRateTest extends LXPattern {

  private static final int NUM_GROUPS = 5;
  

  public final CompoundParameter speed = new CompoundParameter("Speed", 2000, 10000, 500);
  public final CompoundParameter base = new CompoundParameter("Base", 10, 60, 1);
  public final CompoundParameter floor = new CompoundParameter("Floor", 20, 0, 100);

  public final LXModulator[] pos = new LXModulator[NUM_GROUPS];

  public final LXModulator swarmX = startModulator(new SinLFO(
    startModulator(new SinLFO(0, .2, startModulator(new SinLFO(3000, 9000, 17000).randomBasis()))), 
    startModulator(new SinLFO(.8, 1, startModulator(new SinLFO(4000, 7000, 15000).randomBasis()))), 
    startModulator(new SinLFO(9000, 17000, 33000).randomBasis())
    ).randomBasis());

  public final LXModulator swarmY = startModulator(new SinLFO(
    startModulator(new SinLFO(0, .2, startModulator(new SinLFO(3000, 9000, 19000).randomBasis()))), 
    startModulator(new SinLFO(.8, 1, startModulator(new SinLFO(4000, 7000, 13000).randomBasis()))), 
    startModulator(new SinLFO(9000, 17000, 33000).randomBasis())
    ).randomBasis());

  public final LXModulator swarmZ = startModulator(new SinLFO(
    startModulator(new SinLFO(0, .2, startModulator(new SinLFO(3000, 9000, 19000).randomBasis()))), 
    startModulator(new SinLFO(.8, 1, startModulator(new SinLFO(4000, 7000, 13000).randomBasis()))), 
    startModulator(new SinLFO(9000, 17000, 33000).randomBasis())
    ).randomBasis());

  public FrameRateTest(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("base", this.base);
    addParameter("floor", this.floor);
    for (int i = 0; i < pos.length; ++i) {
      final int ii = i;
      pos[i] = new SawLFO(0, LeafAssemblage.NUM_LEAVES, new FunctionalParameter() {
        public double getValue() {
          return speed.getValue() + ii*500;
        }
      }
      ).randomBasis();
      startModulator(pos[i]);
    }
  }
  int frameCount = 0; 
  public void run(double deltaMs) {
    frameCount++;
    float base = this.base.getValuef();
    float swarmX = this.swarmX.getValuef();
    float swarmY = this.swarmY.getValuef();
    float swarmZ = this.swarmZ.getValuef();
    float floor = this.floor.getValuef();
    frameCount = frameCount % 50; 
    int c = lx.hsb(frameCount * 50 % 360, 100, map(frameCount * 10, 0, 500,  60, 100));
    int i = 0;
    for (LeafAssemblage assemblage : tree.assemblages) {
      float pos = this.pos[i++ % NUM_GROUPS].getValuef();
      for (Leaf leaf : assemblage.leaves) {
        float falloff = min(100, base + 40 * dist(leaf.point.xn, leaf.point.yn, leaf.point.zn, swarmX, swarmY, swarmZ));
        float b = max(floor, 100 - falloff * LXUtils.wrapdistf(leaf.orientation.index, pos, LeafAssemblage.LEAVES.length));
        setColor(leaf, lx.hsb(hue(c), saturation(c),b));

        // setColor(leaf, palette.getColor(leaf.point, b)));
      }
    }
  }
}
public class SoundSplines extends LXPattern {
  // by Alexander Green 
  public int NUM_PARTICLES = 10; 
  public final String author = "Alexander F. Green"; 
  ArrayList<LXVector> positions = new ArrayList<LXVector>();
  private PImage moss = loadImage("../data/MossyTrees.jpg");

  
  final int FRAME_WIDTH = 60;
  public GraphicMeter eq = null;
  private float[] bass = new float[FRAME_WIDTH];
  private float[] treble = new float[FRAME_WIDTH];
    
  private int index = 0; 
  public SinLFO xPos = new SinLFO(model.xMax, model.xMin, 5000);
  public SinLFO zPos = new SinLFO(model.zMin, model.zMax, 5000);
  public final CompoundParameter radius =
    new CompoundParameter("Size", 1*FEET, 0*FEET, 10*FEET)
    .setDescription("Radius of the circle");
    
  public final CompoundParameter rate =
    new CompoundParameter("Rate", 6000, 18000)
    .setDescription("Rate of the of the motion");
  
  public final CompoundParameter xPosP =
    new CompoundParameter("xPosP", model.xMin, model.xMax)
    .setDescription("Radius of the circle");
    
  public final CompoundParameter yPosP =
    new CompoundParameter("yPosP", model.yMin, model.yMax)
    .setDescription("Rate of the of the motion");
  
  public final CompoundParameter zPosP =
    new CompoundParameter("zPosP", model.zMin, model.zMax)
    .setDescription("Rate of the of the motion");
  
  private final SawLFO phase = new SawLFO(0, TWO_PI, rate);
  
  public SoundSplines(LX lx) {
    super(lx);
    for (int i = 0; i < FRAME_WIDTH; ++i) {
      bass[i] = 0;
      treble[i] = 0;
    }
    for (int j = 0; j < NUM_PARTICLES; j++) {
      positions.add(new LXVector(0,0,0));
    }
    startModulator(xPos);
    startModulator(zPos);
    xPos.setBasis(.25);
    startModulator(phase);
    addParameter(radius);
    addParameter(rate);
    addParameter(xPosP);
    addParameter(yPosP);
    addParameter(zPosP);
  }
    
  public void onActive() {
     if (eq == null) {
      eq = new GraphicMeter(lx.engine.audio.getInput()); 
      // eq.slope.setValue(6);
      // eq.gain.setValue(12);
      // eq.range.setValue(36);
      // eq.release.setValue(500);
      // addParameter(eq.gain);
      // addParameter(eq.range);
      // addParameter(eq.attack);
      // addParameter(eq.release);
      // addParameter(eq.slope);
      addModulator(eq).start();
    }
  }
  int counter = 0; 

  public void run(double deltaMs) {
    setColors(#000000);
     counter++; 
    //position.set(500*cos((float)counter/100), model.cy,500*sin((float)counter/100));
    //position.set(xPos.getValuef(), model.cy, zPos.getValuef());
    positions.get(0).set(xPosP.getValuef(),yPosP.getValuef(), zPosP.getValuef());
    for (Leaf leaf : tree.leaves) {
      float dist = abs(positions.get(0).dist(leaf.coords[0]));

      if (dist < radius.getValuef()) {
        setColor(leaf, moss.get(leaf.point.index%100, leaf.point.index%50));
      }

    }
  }
}
   

public class SoundParticles extends LXPattern {
    private final int LIMINAL_KEY = 46; 
    private final int MAX_VELOCITY = 100; 
    private boolean debug = false; 
    private boolean doUpdate= false;   
    public  LXProjection spinProjection; 
    public  LXProjection scaleProjection; 
   // public  LXProjection 
    //private LeapMotion leap; 
    public  GraphicMeter eq = null;
    public  BoundedParameter spark = new BoundedParameter("Spark", 0); 
    public  BoundedParameter magnitude = new BoundedParameter("Mag", 0.1, 1);
    public  BoundedParameter scale = new BoundedParameter("scale", 1, .8, 1.2); 
    public  BoundedParameter spin  = new BoundedParameter("Spin", .5 , 0, 1); 
    public  BoundedParameter sizeV = new BoundedParameter("Size", 3.5, 0, 10); 
    public  BoundedParameter speed = new BoundedParameter("Speed", 16, 0, 500); 
    public  BoundedParameter colorWheel = new BoundedParameter("Color", 0, 0, 360); 
    public  BoundedParameter wobble = new BoundedParameter("wobble", 1, 0, 10); 
    public  BoundedParameter radius = new BoundedParameter("radius", 2000, 500, 2500); 
    private ArrayList<Particle> particles = new ArrayList<Particle>(); 
    public  ArrayList<SinLFO> xPos = new ArrayList<SinLFO>();
    public  ArrayList<SinLFO> yPos = new ArrayList<SinLFO>();
    public  ArrayList<SinLFO> zPos = new ArrayList<SinLFO>();
    public  ArrayList<SinLFO> wobbleX = new ArrayList<SinLFO>();
    public  ArrayList<SinLFO> wobbleY = new ArrayList<SinLFO>();
    public  ArrayList<SinLFO> wobbleZ = new ArrayList<SinLFO>();
    public  PVector startVelocity = new PVector(); 
    private PVector modelCenter = new PVector(); 
    public  SawLFO angle = new SawLFO(0, TWO_PI, 1000); 
    private float[] randomFloat = new float[model.points.length];
    private float[] freqBuckets; 
    private float lastParticleBirth = millis(); 
    private float lastTime = millis(); 
    private float lastTransmitEQ = millis();
    private int prints = 0; 
    private float sparkX = 0.; 
    private float sparkY = 0.; 
    private float sparkZ = 0.; 
    private float randCtr (float a) { 
      return random(a) - a*.5; 
    }
    private float midiToHz(int key ) {
          return (float) (440 * pow(2, (key - 69) / 12)); 
          }
    private float midiToAngle(int key ) {
           return (2 * PI / 24) * key;  
          }
    
    
    ArrayList<MidiNoteStamp> lfoNotes = new ArrayList<MidiNoteStamp>(); 
    MidiNote[] particleNotes = new MidiNote[128]; 

      class MidiNoteStamp {
        MidiNote note; 
        float timestamp; 
          MidiNoteStamp(MidiNote _note) {
          note =_note; 
          timestamp = millis()* .001; 
          }
        } 
       class Particle  { 
        PVector position= new PVector(); 
        PVector velocity= new PVector(); 
        PVector distance = new PVector();
        PVector modDist = new PVector();  
        float hue; 
        float life; 
        float intensity; 
        float falloff; 
        int i = 0; 
          Particle(PVector pos, PVector vel) {
            position.set(pos);     
            velocity.set(vel); 
            life=1; 
            intensity=1; 
            falloff=1; 
            hue =220.; 
            i = particles.size(); 
            float rand = randomGaussian(); 
            float rand2 = randomGaussian();
            SinLFO x = new SinLFO(-rand*20, rand2*20,1500+ 500*rand2);
            startModulator(x);
            xPos.add(x);
            SinLFO y = new SinLFO(-rand2*20, rand*20, 1500 + 500*rand2);
            startModulator(y);
            yPos.add(y);
            wobbleX.add(new SinLFO(6000, 1000, 2000)); 
          }
          Particle(PVector pos, PVector vel, MidiNote note) {
            position.set(pos);     
            velocity.set(vel); 
            life=1; 
            intensity=1; 
            falloff=1;
            this.hue=220.; 
          }
          public  boolean isActive() {
             if (abs(this.position.dist(modelCenter)) >= radius.getValuef()) {
              if( millis() %100 < 5 ) {
             // println("particle distance to center:  " +   abs(this.position.dist(modelCenter)));
             // println("particle distance:  " +  distance); 
              };
              //  println("position" + this.position + "modelCenter:  " +   modelCenter); 
              //  println("particle inactive"); 
                return false; 
                }
              else 
                //println("position" + this.position + "modelCenter:  " +   modelCenter); 
                //println("particle active"); 
                return true; 
              }

          public void respawn() {
            //this.position.set(modelCenter.mult(random(.5,1.2))); 
            PVector randomG = 
            new PVector(model.cx + randomGaussian()*model.xMax/4, model.cy + randomGaussian()*model.yMax/4, model.cz + randomGaussian()*model.yMax/4);
            this.position.set(randomG);
            PVector toCenter = modelCenter.sub(randomG).normalize();

            this.velocity.set(toCenter).setMag(1);
            this.hue=120 + randomGaussian()*30; 
          } 

          public  color CalculateColor(LXPoint p ) { 

              return lx.hsb(0,0,0); 
          }
          public  void run(double deltaMs) {
            if (!this.isActive()){
            respawn(); 
            } 

            float spinNow = spin.getValuef(); 
            float sparkf = spark.getValuef(); 
            float clock = 0.001 * millis();

            if (spinNow != 0){
                if (spinNow > 0) {angle.setRange((double)0.0, (double)TWO_PI, 1000-spinNow);}
                else if (spinNow < 0) {angle.setRange(angle.getValuef(), angle.getValuef() - TWO_PI, (double) 1000 - spinNow);}
             
             spinProjection
             .center()
             .rotate((spinNow - .5) / 100 , 0,0,1)
             .translate(model.cx, model.cy, model.cz);  
            //  .scale(scale.getValuef(),scale.getValuef(),scale.getValuef()); 
             }
          
            float move = ((float)deltaMs/ 1000)*10*speed.getValuef(); 
            PVector distance = PVector.mult(velocity, move); 
            position.add(distance); 
            //modDist.set(PVector.random3D().setMag(10)); 
             modDist.set(xPos.get(i).getValuef()/2, yPos.get(i).getValuef()/2); 
          
            //modDist.set(sin((float)deltaMs/1000)*2,sin((float)deltaMs/1000 + PI/4)*2); 
            position.add(modDist);
            float size = sizeV.getValuef(); 
            float avgBass = eq.getAveragef(0,4); 
            float avgMid = eq.getAveragef(6,6); 
            float avgTreble= eq.getAveragef(12,6); 
            float hueShift = 10; 
            hueShift = hueShift * avgTreble*10;  
            int i = 0; 
              
            //  for (LXVector p : spinProjection) {
             for (Leaf leaf : tree.leaves) {

                float randomX = randomFloat[i];  
                 //float randomY = randctr(20); 
                 //float randomZ = randctr(20); 
                float sparkle = randomX*sparkf; 
              // asin(p.y-position.y/ dist(p.x, p.y,position.x, position.y));                
               // float b =0; 
               // float thetaP = atan2((p.y - position.y), (p.x - position.x));  //too slow 
               // float b = 100 - (pow(p.x-(position.x),2) + pow(p.y - (position.y), 2) + pow(p.z - (position.z), 2))/((10+6*avgBass)*size); 
                float b = 100 - (pow(leaf.x-(position.x + sparkle),2) + pow(leaf.y - (position.y + sparkle), 2) + pow(leaf.z - (position.z+ randomX*sparkle), 2))/((10+6*avgBass)*10*size); 

                if (b >0){
                  addColor(leaf, lx.hsb(this.hue+hueShift, map(1-avgTreble, 0,1, 0, 100), b));

                 // blendColor(p.index, lx.hsb(this.hue+hueShift, map(1-avgTreble, 0,1, 0, 100), b), LXColor.Blend.ADD);
                }
               i++; 
            }
           position.sub(modDist);
          }
        } 
    public  SoundParticles(LX lx) {
      super(lx);
      for (int i = 0 ; i < model.points.length; i++) {
        randomFloat[i]=randomGaussian()*10; 
      }
   
      spinProjection = new LXProjection(model); 
      scaleProjection = new LXProjection(model); 
      addParameter(spark);
      addParameter(magnitude); 
      addParameter(sizeV); 
      addParameter(speed); 
      addParameter(spin); 
      addParameter(colorWheel); 
      addParameter(wobble); 
      addParameter(radius);
      startModulator(angle);
      //addModulator(xPos).trigger();
      //addModulator(yPos).trigger();
      //addModulator(zPos).trigger();
      modelCenter.set(model.cx, model.cy, model.cz); 
      //modelCenter.set(0.0f, 0.0f,0.0f);
      // println("modelCenter = " + modelCenter); 
      // println("model.cx:  " + model.cx + "model.cy:  " + model.cy + "model.cz:  " + model.cz); 

      }

    public boolean noteOn(MidiNote note)  { 

        if (note.getPitch() < LIMINAL_KEY ){ 
            lfoNotes.add(new MidiNoteStamp(note)); 
            return false; 
          }

        float angle = map(note.getPitch(), 30, 50,  0, TWO_PI); 
        float velocity = map(note.getVelocity(), 0, 127, 0, 1);                                           ;
        particles.add( new Particle(modelCenter.add(new PVector(random(-model.xMax/4,model.xMax/4), random(-model.yMax/4, model.yMax/4), 0)), new PVector( cos(angle)*velocity, sin(angle)*velocity, 0))); 
     

        return false;
    }

    private void debugFloat(String name, float num, float interval) {
      if (prints > 500) return; 
      if (prints < 500) {
      println(name + num); 
      }
      prints++; 
      
    }

      
    public void onParameterChanged(LXParameter p ) {
      if (p == wobble){
        for (SinLFO x : xPos){
          x.setRangeFromHereTo(p.getValuef()*100 + randomGaussian()*10);
        }
        for (SinLFO y : yPos){
          y.setRangeFromHereTo(p.getValuef()*100 + randomGaussian()*10);
        }
        return;
       }
      if (p == colorWheel) {
        float val = p.getValuef();
     }
        return; 
      }


    PVector randomVector() { return new PVector(random(-model.xMax/4, model.xMax/4), random(-model.yMax/4, model.yMax/4), 0);}
   
    
    
    public void onActive()  {
      if (eq == null ) {
        eq = new GraphicMeter(lx.engine.audio.input);
        eq.slope.setValue(6);
        eq.range.setValue(36);
        eq.attack.setValue(10);
        eq.release.setValue(640);
        eq.gain.setValue(.3); 
        addModulator(eq).start();
        freqBuckets = new float[eq.numBands]; 
      }
 
      for (int i=0; i<10; i++){
     // particles.add(new Particle(PVector.random3D().setMag(model.xMax/2).add(modelCenter), PVector.random3D().setMag(.1))); 
      particles.add(new Particle(modelCenter.add(randomVector().setMag(50.)), PVector.random3D())); 

      }
    }

    public void run(double deltaMs) {
     setColors(0); 
     sparkX = randCtr(20); 
     sparkY = randCtr(20);
     sparkZ = randCtr(20); 
     for (Particle p : particles)
      {
      p.run(deltaMs); 
      }
    }
 }
 
public class Turbulence extends LXPattern {
  //by Alexander Green 
   public final String author = "Alexander F. Green"; 

  private class FluidData implements DwFluid2D.FluidData{
    
    // update() is called during the fluid-simulation update step.
    @Override
    public void update(DwFluid2D fluid) {
    
      float px, py, vx, vy, radius, vscale, r, g, b, intensityV, temperature;
      
      // add impulse: density + temperature
      intensityV = 0.2f*intensity.getValuef();
      px = 1*200/3;
      py = 0;
      radius = 30*size.getValuef();
      r = 0.0f;
      g = 0.3f;
      b = 1.0f;
      fluid.addDensity(px, py, radius, r, g, b, intensityV);

      if((fluid.simulation_step) % 200 == 0){
        temperature = 50f;
        fluid.addTemperature(px, py, radius, temperature);
      }
      
      // add impulse: density + temperature
      float animator = sin(fluid.simulation_step*0.01f);
 
      intensityV = 1.0f*intensity.getValuef();
      px = 2*200/3f;
      py = 150;
      radius = 25*size.getValuef();
      r = 0.3f;
      g = 0.2f;
      b = 0.8f;
      fluid.addDensity(px, py, radius, r, g, b, intensityV);
      
      temperature = animator * 20f;
      fluid.addTemperature(px, py, radius, temperature);
      
      
      // add impulse: density 
      px = 1*200/3f;
      py = 200-2*200/3f;
      radius = 20.0f*size.getValuef();
      r = g = 150/255f;
      b = 1f;
      intensityV = 1.0f*intensity.getValuef();
      fluid.addDensity(px, py, radius, r, g, b, intensityV, 3);

        
      // add impulse: density 
      px = 200f/1.5;
      py = 200-2*200/3f;
      radius = 20.0f*size.getValuef();
      r = b = 115/255f;
      g =0.0f;

      intensityV = 1.0f*intensity.getValuef();
      fluid.addDensity(px, py, radius, r, g, b, intensityV, 3);
    }
  }
  
 //fluid system
  int viewport_w = 200;
  int viewport_h = 200;
  final int SIZE_OF_FLUID = viewport_h*viewport_w;
  int fluidgrid_scale = 1;
  
  DwPixelFlow context; 
  DwFluid2D fluid;
  //ObstaclePainter obstacle_painter;
  PGraphics2D pg_fluid;   // render targets
  PGraphics2D pg_obstacles;   //texture-buffer, for adding obstacles
  PGraphics2D pg_fluid2; //extra buffer for debugging 
  PImage moss = loadImage("../data/MossyTrees.jpg");
  // some state variables for the GUI/display
  int     BACKGROUND_COLOR           = 0;
  boolean UPDATE_FLUID               = true;
  boolean DISPLAY_FLUID_TEXTURES     = true;
  boolean DISPLAY_FLUID_VECTORS      = false;
  // int     fluidDisplayMode = 2;
  int[] tempColors = new int[SIZE_OF_FLUID + 200]; //200 is to add extra pixels in

  public GraphicMeter eq = null;
  
  public final DiscreteParameter fluidDisplayMode =
    new DiscreteParameter("Mode", 0, 4 )
    .setDescription("Fluid Display Mode");

  public final DiscreteParameter colorMode =
    new DiscreteParameter("Colors", 0, 4)
    .setDescription("Switch Between Coloring Schemes");
  public final CompoundParameter speed =
    new CompoundParameter("Speed", 6000, 18000)
    .setDescription("Speed of fluid movement");
  public final CompoundParameter size =
    new CompoundParameter("size", 1, 0, 3)
    .setDescription("Size of fluid sources");
    public final CompoundParameter intensity =
    new CompoundParameter("intensity", 1, 0, 3)
    .setDescription("intensity");
  
  private final SawLFO phase = new SawLFO(0, TWO_PI, speed);
  
  private final double[] bins = new double[512];
  
  public Turbulence(LX lx) {
    super(lx);
    eq = new GraphicMeter(lx.engine.audio.input);
    startModulator(eq);
    startModulator(phase);
    addParameter(fluidDisplayMode);
    addParameter(colorMode);
    addParameter(speed);
    addParameter(size);
    addParameter(intensity);
    context = new DwPixelFlow(Tenere.this);
    context.print();
    context.printGL();
    fluid = new DwFluid2D(context, 200, 200, 1);
    // set some simulation parameters
    fluid.param.dissipation_density     = 0.999f;
    fluid.param.dissipation_velocity    = 0.99f;
    fluid.param.dissipation_temperature = 0.80f;
    fluid.param.vorticity               = 0.10f;
    
    // interface for adding data to the fluid simulation
    FluidData fluidData = new FluidData();
    fluid.addCallback_FluiData(fluidData);
   
    //pgraphics for fluid
    pg_fluid = (PGraphics2D) createGraphics(200, 200, P2D);
    pg_fluid.smooth(4);
    pg_fluid.beginDraw();
    pg_fluid.background(BACKGROUND_COLOR);
    pg_fluid.endDraw();
    pg_fluid.loadPixels();
    // // pgraphics for obstacles
    // pg_obstacles = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
    // pg_obstacles.smooth(0);
    // pg_obstacles.beginDraw();
    // pg_obstacles.clear();
    // // circle-obstacles
    // pg_obstacles.strokeWeight(10);
    // pg_obstacles.noFill();
    // pg_obstacles.noStroke();
    // pg_obstacles.fill(64);
    // float radius;
    // radius = 100;
    // pg_obstacles.ellipse(1*width/3f,  2*_height/3f, radius, radius);
    // radius = 150;
    // pg_obstacles.ellipse(2*width/3f,  2*_height/4f, radius, radius);
    // radius = 200;
    // pg_obstacles.stroke(64);
    // pg_obstacles.strokeWeight(10);
    // pg_obstacles.noFill();
    // pg_obstacles.ellipse(1*width/2f,  1*_height/4f, radius, radius);
    // // border-obstacle
    // pg_obstacles.strokeWeight(20);
    // pg_obstacles.stroke(64);
    // pg_obstacles.noFill();
    // pg_obstacles.rect(0, 0, pg_obstacles.width, pg_obstacles._height);

    // pg_obstacles.endDraw();
    
    // class, that manages interactive drawing (adding/removing) of obstacles
    //obstacle_painter = new ObstaclePainter(pg_obstacles);
  }

    public void fluid_reset(){
      fluid.reset();
    }
    public void fluid_togglePause(){
      UPDATE_FLUID = !UPDATE_FLUID;
    }
    public void fluid_displayMode(int val){
   //   fluidDisplayMode = val;
     // DISPLAY_FLUID_TEXTURES = fluidDisplayMode != -1;
    }
    public void fluid_displayVelocityVectors(int val){
      DISPLAY_FLUID_VECTORS = val != -1;
    }

  public void run(double deltaMs) {
    // update simulation
    if(UPDATE_FLUID){
   //   fluid.addObstacles(pg_obstacles)
      fluid.update();
    }
    // clear render target
    pg_fluid.beginDraw();
    pg_fluid.background(BACKGROUND_COLOR);
    pg_fluid.endDraw();
    // render fluid stuff
    //pg_fluid.loadPixels();
    //println("pg_fluid pixels loaded: " + pg_fluid.loaded);
    if(DISPLAY_FLUID_TEXTURES){
       //render: density (0), temperature (1), pressure (2), velocity (3)
      fluid.renderFluidTextures(pg_fluid, fluidDisplayMode.getValuei());

    }
    
      //println("fluid pixels loaded: " + fluid.loaded);
      // render: velocity vector field
    // fluid.renderFluidVectors(pg_fluid, 10);
    
    // display

    //  image(pg_fluid, 200, 0);
   // image(pg_obstacles, 0, 0);
   //   pg_fluid.loadPixels();

     pg_fluid.loadPixels();
     for (int x=0; x<pg_fluid.width; x++){
      for (int y=0; y<pg_fluid.height; y++){
        int location = x + y*pg_fluid.width; 
        tempColors[location]=pg_fluid.pixels[location];
       }
     }
     pg_fluid.updatePixels();


    for (LXPoint p : model.points) {
      
      float positionX = abs((p.x - model.xMin)/(model.xMax - model.xMin)); //to-do: make this faster by caching this 
      float positionY = abs((p.z - model.zMin)/(model.zMax - model.zMin));
      int fluidPixelX= floor(positionX*pg_fluid.width);  //gets the corresponding pixel in the fluid data array 
      int fluidPixelY= floor(positionY*pg_fluid.height);  
      int pixel = fluidPixelX + fluidPixelY*(pg_fluid.width);
      //println("fluidpixelX: "+fluidPixelX + "fluidpixelY: " + fluidPixelY);
      // int r = (tempColors[i] >> 16) & OxFF;
      // int g = (tempColors[i] >> 8) & OxFF;
      // int b = tempColors[i] & OxFF;
      switch(colorMode.getValuei()) {
        case 0: colors[p.index] = tempColors[pixel]; 
                break;
        case 1: float b = brightness(tempColors[pixel]);
                colors[p.index] = b > 0 ? palette.getColor(p, b) : #000000;
                break;
        case 2: float _b = brightness(tempColors[pixel]);
                colors[p.index] = _b > 0 ? moss.get(fluidPixelX,fluidPixelY) : #000000;
          

          }
      
      }
    
  }
}

public class Pong extends APat {
  SinLFO x,y,z,dx,dy,dz;
  float cRad; BoundedParameter pSize;
  DiscreteParameter   pChoose;
  PVector v = new PVector(), vMir =  new PVector();

  Pong(LX lx) {
    super(lx);
    cRad = mMax.x/10;
    startModulator(dx = new SinLFO(6000,  500, 30000  ));
    startModulator(dy = new SinLFO(3000,  500, 22472  ));
    startModulator(dz = new SinLFO(1000,  500, 18420  ));
    startModulator(x  = new SinLFO(cRad, mMax.x - cRad, 0));  x.setPeriod(dx);
    startModulator(y  = new SinLFO(cRad, mMax.y - cRad, 0));  y.setPeriod(dy);
    startModulator(z  = new SinLFO(cRad, mMax.z - cRad, 0));  z.setPeriod(dz);
      pSize = addParam  ("Size"     , 0.4 );
      pChoose = new DiscreteParameter("Anim", new String[] {"Pong", "Ball", "Cone"} );
      pChoose.setValue(2);
      addParameter(pChoose);
  }

  void    StartRun(double deltaMs)  { cRad = mMax.x*val(pSize)/6; }
  color CalculateColor(PVector p)      {
    v.set(x.getValuef(), y.getValuef(), z.getValuef());
    v.z=0;p.z=0;// ignore z dimension
    switch(pChoose.getValuei()) {
    case 0: vMir.set(mMax); vMir.sub(p);
        return lx.hsb(lxh(),100,c1c(1 - min(v.dist(p), v.dist(vMir))*.5/cRad));   // balls
    case 1: return lx.hsb(lxh(),100,c1c(1 - v.dist(p)*.5/cRad));              // ball
    case 2: vMir.set(mMax.x/2,0,mMax.z/2);
        return lx.hsb(lxh(),100,c1c(1 - calcCone(p,v,vMir) * max(.02,.45-val(pSize))));   // spot
    }
    return lx.hsb(0,0,0);
  }
}
//----------------------------------------------------------------------------------------------------------------------------------
public class NDat {
  float   xz, yz, zz, hue, speed, angle, den;
  float xoff,yoff,zoff;
  float sinAngle, cosAngle;
  boolean isActive;
  NDat      () { isActive=false; }
  boolean Active() { return isActive; }
  void  set   (float _hue, float _xz, float _yz, float _zz, float _den, float _speed, float _angle) {
    isActive = true;
    hue=_hue; xz=_xz; yz=_yz; zz =_zz; den=_den; speed=_speed; angle=_angle;
    xoff = random(100e3); yoff = random(100e3); zoff = random(100e3);
     
  }
}

public class Fall extends APat
{
  int       CurAnim, iSymm;
  int       XSym=1,YSym=2,RadSym=3;
  float       zTime , zTheta=0, zSin, zCos, rtime, ttime;
  BoundedParameter  pSpeed , pDensity, pSharp, cutoff; 
  DiscreteParameter     pChoose, pSymm;
  int       _ND = 4;
  NDat      N[] = new NDat[_ND];

  public Fall(LX lx) {
    super(lx);
    pSpeed = new BoundedParameter("Fast", .55, -2, 2); 
    addParameter(pSpeed);
    pDensity  = addParam("Dens"    , .3);
    cutoff = addParam("Cut", .5);
    pSharp    = addParam("Shrp"    ,  0);
    pSymm     = new DiscreteParameter("Symm" , new String[] {"None", "X", "Y", "Rad"} );
    pChoose   = new DiscreteParameter("Anim", new String[] {"Drip", "Cloud", "Rain", "Fire", "Mach", "Spark","VWav", "Wave"}  );
    pChoose.setValue(5);
    addParameter(pSymm);
    addParameter(pChoose);
    for (int i=0; i<_ND; i++) N[i] = new NDat();
  }

  void onActive() { zTime = random(500); zTheta=0; rtime = 0; ttime = 0; }

  void StartRun(double deltaMs) {
    zTime   += deltaMs*(1*val(pSpeed)-.50) * .005;
    zTheta  += deltaMs*(spin()-.5)*.01  ;
    rtime += deltaMs;
    iSymm  = pSymm.getValuei();
    zSin  = sin(zTheta);
    zCos  = cos(zTheta);

    if (pChoose.getValuei() != CurAnim) {
      CurAnim = pChoose.getValuei(); ttime = rtime;
      pSpin   .reset(); zTheta    = 0;
      pDensity  .reset(); pSpeed    .reset();
      for (int i=0; i<_ND; i++) { N[i].isActive = false; }
      
      switch(CurAnim) {
      //               hue xz  yz  zz den mph angle
      case 0: N[0].set(0  ,75 ,75 ,150,45 ,3  ,0  ); 
              N[1].set(20, 25, 50, 50, 25, 1, 0 ); 
                    N[2].set(80, 25, 50, 50, 15, 2, 0 );  
                    pSharp.setValue(1 );   break;  // drip
      case 1: N[0].set(0  ,100,100,200,45 ,3  ,180); pSharp.setValue(0 ); break;  // clouds
      case 2: N[0].set(0  ,2  ,400,2  ,20 ,3  ,0  ); pSharp.setValue(.5); break;  // rain
      case 3: N[0].set(40 ,100,100,200,10 ,1  ,180); 
          N[1].set(0  ,100,100,200,10 ,5  ,180); pSharp.setValue(0 ); break;  // fire 1
      case 4: N[0].set(0  ,40 ,40 ,40 ,15 ,2.5,180);
          N[1].set(20 ,40 ,40 ,40 ,15 ,4  ,0  );
          N[2].set(40 ,40 ,40 ,40 ,15 ,2  ,90 );
                    N[3].set(60 ,40 ,40 ,40 ,15 ,3  ,-90); pSharp.setValue(.5); break; // machine       
      case 5: N[0].set(0  ,400,100,2  ,15 ,3  ,90 );
          N[1].set(20 ,400,100,2  ,15 ,2.5,0  );
          N[2].set(40 ,100,100,2  ,15 ,2  ,180);
          N[3].set(60 ,100,100,2  ,15 ,1.5,270); pSharp.setValue(.5); break; // spark
      }
    }
    
    for (int i=0; i<_ND; i++) if (N[i].Active()) {
      N[i].sinAngle = sin(radians(N[i].angle));
      N[i].cosAngle = cos(radians(N[i].angle));
    }
  }

  color CalculateColor(PVector p) {
    color c = 0;
    rotateZ(p, mCtr, zSin, zCos);
        //rotateY(p, mCtr, ySin, yCos);
        //rotateX(p, mCtr, xSin, xCos); 
    if (CurAnim == 6 || CurAnim == 7) {
      setNorm(p);
      return lx.hsb(lxh(),100, 100 * (
              constrain(1-50*(1-val(pDensity))*abs(p.y-sin(zTime*10  + p.x*(300))*.5 - .5),0,1) + 
      (CurAnim == 7 ? constrain(1-50*(1-val(pDensity))*abs(p.x-sin(zTime*10  + p.y*(300))*.5 - .5),0,1) : 0))
      );
    }     

    if (iSymm == XSym && p.x > mMax.x/2) p.x = mMax.x-p.x;
    if (iSymm == YSym && p.y > mMax.y/2) p.y = mMax.y-p.y;

    for (int i=0;i<_ND; i++) if (N[i].Active()) {
      NDat  n     = N[i];
      float zx    = zTime * n.speed * n.sinAngle,
          zy    = zTime * n.speed * n.cosAngle;

      float b     = (iSymm==RadSym ? (zTime*n.speed+n.xoff-p.dist(mCtr)/n.xz)
                     : noise(p.x/n.xz+zx+n.xoff,p.y/n.yz+zy+n.yoff,p.z/n.zz+n.zoff))
              *1.8;

      b +=  n.den/100 -.4 + val(pDensity) -1;

    c =   PImage.blendColor(c,lx.hsb(palette.getHuef()+n.hue,100,c1c(b)),ADD);
    }
    if (brightness(c) < cutoff.getValuef()) return LXColor.BLACK;
    else return c; 
    //brightness(c) > .4 ? return c : return LXColor.BLACK;
    // return c;
  }
}