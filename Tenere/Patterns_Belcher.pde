import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;

//TO-DO:
//Change elapsedMs to this.runMS

public class AtomPattern extends LXPattern {
  // by Justin Belcher
  //
  // Note: The fun parameters are at the end.  Check out Wobble Width, Wobble Frequency, and Wander.
   
  private static final float RADIANS_PER_REVOLUTION = 2.0f;
  private static final int NUMBER_OF_ELECTRONS = 2;

  //Overall parameters
  public final CompoundParameter nucleusSize =
    new CompoundParameter("SizeNucleus", 0.5, 0, 1)
    .setDescription("Size of the nucleus, relative to structure");
  public final CompoundParameter nucleusHue = 
    new CompoundParameter("HueNucleus", LXColor.h(LXColor.RED), 0, 360)
    .setDescription("Color hue of nucleus");
  
  LXTransform transform1;
  float structureRadius;
    
  public AtomPattern(LX lx) {
    super(lx);

    addParameter(nucleusSize);
    addParameter(nucleusHue);
    
    //Center the pattern in the middle of all points
    transform1=new LXTransform();
    transform1.translate(lx.cx, lx.cy, 0);
    
    //Calculate structure size, as size parameters in this pattern are a percentage of the entire structure
    structureRadius = Math.max(model.xRange, model.yRange) / 2;
    
    //Electrons
    for (int i = 1; i <= NUMBER_OF_ELECTRONS; i++) {
      
      ElectronLayer electronLayer = new ElectronLayer(lx, this, transform1); 
      addLayer(electronLayer);
      
      //Initialize electron parameters
      electronLayer.pathRadius.setValue(Math.max(1.0 - (0.2 * i), 0.2));  //Stagger the path radius
      electronLayer.enableElectron.setValue((i == 1) ? true : false);    //Only one electron visible to start
      electronLayer.tilt.setValue(((i-1)*60)%180);              //Offset the tilt of each electron
      electronLayer.orient.setValue(((i-1)*60)%360);            //Offset the orientation of each electron
      
      //Add the electron parameters to the Atom pattern
      addParameter(electronLayer.enableElectron.getLabel() + i, electronLayer.enableElectron);
      addParameter(electronLayer.pathRadius.getLabel() + i, electronLayer.pathRadius);
      addParameter(electronLayer.electronSize.getLabel() + i, electronLayer.electronSize);
      addParameter(electronLayer.tailLength.getLabel() + i, electronLayer.tailLength);
      addParameter(electronLayer.tailHueOffset.getLabel() + i, electronLayer.tailHueOffset);
      addParameter(electronLayer.velocity.getLabel() + i, electronLayer.velocity);
      addParameter(electronLayer.tilt.getLabel() + i, electronLayer.tilt);
      addParameter(electronLayer.spin.getLabel() + i, electronLayer.spin);
      addParameter(electronLayer.orient.getLabel() + i, electronLayer.orient);
      addParameter(electronLayer.wobbleWidth.getLabel() + i, electronLayer.wobbleWidth);
      addParameter(electronLayer.wobbleFrequency.getLabel() + i, electronLayer.wobbleFrequency);
      addParameter(electronLayer.wander.getLabel() + i, electronLayer.wander);
    }
  }

  protected double elapsedMs = 0;
  
  @Override
  protected void run(double deltaMs) {
    this.elapsedMs += deltaMs;
        
    setColors(LXColor.BLACK);
    
    //Nucleus calculations
    float nucleusRadius = structureRadius * this.nucleusSize.getValuef();
    LXVector nucleusPos = this.transform1.vector();
    int nucleusColor = LXColor.hsb(this.nucleusHue.getValuef(), 100, 100);
    
    for (LXPoint p : model.points) {
      //Draw nucleus
      float distToNucleus = dist(nucleusPos, p);      
      if (distToNucleus<nucleusRadius) {
        //Point is within nucleus
        colors[p.index] = nucleusColor;
      }      
    }
    
    //Electrons will be drawn by the child layers
  }
  
  protected float dist(LXVector vector, LXPoint point) {
    float dx = vector.x - point.x;
    float dy = vector.y - point.y;
    float dz = vector.z - point.z;
    return (float) Math.sqrt(dx*dx + dy*dy + dz*dz);
  }
  
  
  private class ElectronLayer extends LXLayer {
    
    private static final float MAX_TAIL_BRIGHTNESS = 0.85f;

    public AtomPattern parent;

    //Basic Electron Properties
    public final BooleanParameter enableElectron =
      new BooleanParameter("Enable")
      .setDescription("Turn this electron on/off")
      .setMode(BooleanParameter.Mode.TOGGLE);
    public final CompoundParameter pathRadius =
      new CompoundParameter("RadiusElectron", 0.8, 0, 1)
      .setDescription("Radius of electrons path");
    public final CompoundParameter electronSize =
      new CompoundParameter("SizeElectron", 0.2, 0, 1)
      .setDescription("Size of electron, relative to structure");
    public final CompoundParameter tailLength =
      new CompoundParameter("TailLength", 0.95, 0, 1.2)
      .setDescription("Duration of comet-like tail, in seconds");
    public final CompoundParameter tailHueOffset = 
      new CompoundParameter("TailHueOffset", 60, 0, 360)
      .setDescription("Tail hue offset amount, relative to electron.");
    //Simple behavior
    public final CompoundParameter velocity =
      new CompoundParameter("RPM", 80, 0, 1000)
      .setDescription("Velocity (RPM) of electron on its primary path");
    public final CompoundParameter tilt = 
      new CompoundParameter("Tilt", 0, 0, 180)
      .setDescription("Tilt the overall animation.  Good for offsetting the positions of different electrons.");
    public final CompoundParameter spin =
      new CompoundParameter("Spin", 0, 0, 1000)
      .setDescription("Spin has the same effect as tilt but it is continuous. To change the electron speed use RPM.");  
    public final CompoundParameter orient = 
      new CompoundParameter("Orient", 0, 0, 360)
      .setDescription("Orient the path.  Effect is only visible when tilt is not flat.");
    //Fun behavior
    public final CompoundParameter wobbleWidth =
      new CompoundParameter("WobWid", 26, 0, 110)
      .setDescription("Width of the wobble in degrees. 0=no wobble.");
    public final CompoundParameter wobbleFrequency =
      new CompoundParameter("WobFreq", 0.05, 0, 0.5)
      .setDescription("Frequency of wobble, relative to electron revolutions"); 
    public final CompoundParameter wander =
      new CompoundParameter("Wander", 0, 0, 180)
      .setDescription("How much would you wander if you were an electron right now?");
    
    //To-Do: For very slow electron speed, we need the period to be a lot longer
    //x=200, y=1600.  x=5, y=4000?
    private final LXModulator wanderLFO = startModulator(new TriangleLFO(0, this.wander, 1600));
        
    LXTransform transform1;
    private float positionElectron = 0;
    private float positionSpin = 0;
    private float positionWobble = 0;
    private HashMap<LXPoint, TailPoint> tailPoints = new HashMap<LXPoint, TailPoint>();
    
    private ElectronLayer(LX lx, AtomPattern parent, LXTransform transform) { 
      super(lx);
      this.parent = parent;
      this.transform1 = transform;
    }
    
    protected double previousFrame = 0;
    
    public void run(double deltaMs) {
      
      if (!this.enableElectron.getValueb())
        return;
      
      //Electron calculations
      float tilt = this.tilt.getValuef();
      float spin = this.spin.getValuef();
      float orient = this.orient.getValuef();
      float pRadius = this.parent.structureRadius * this.pathRadius.getValuef();
      float eSize = this.parent.structureRadius * this.electronSize.getValuef();
      float velocity = this.velocity.getValuef();
      //WobbleWidth: Theoretical parameter range is 0-180 but we divide that by two because for every degree we tilt the effect is doubled.
      //  In practice the max value is limited on input because the electron behavior gets weird (turns into a sine wave) at high values.
      double wobbleWidthRadians = Math.toRadians((180 - this.wobbleWidth.getValuef()) / 2.0);
      float wobbleVelocity = velocity * (this.wobbleFrequency.getValuef());
      //Reduce electron velocity to compensate for speed added by wobble velocity.
      velocity -= (Math.sin(wobbleWidthRadians)*wobbleVelocity);
      float tailLength = this.tailLength.getValuef();
      float tailHueOffset = this.tailHueOffset.getValuef();
      //"Wander" is created by oscillating a pre-position rotation around the Z-axis.  Why does it work?  Magic.
      float wanderLFO = this.wanderLFO.getValuef();        
      
      //Increment positions for the speed parameters
      this.positionElectron += velocity*RADIANS_PER_REVOLUTION/60.0/1000.0*deltaMs;
      this.positionSpin += spin*RADIANS_PER_REVOLUTION/60.0/1000.0*deltaMs;
      this.positionWobble += wobbleVelocity*RADIANS_PER_REVOLUTION/60.0/1000.0*deltaMs;
      //These positions can run for a long time without mod but they would probably eventually overflow.
      this.positionElectron %= 360.0;
      this.positionSpin %= 360.0;
      this.positionWobble %= 360.0;
      
      //Calculate position of electron through a series of nested rotations.
      //*This might run faster by keeping multiple transforms and multiplying their
      // matrices together, instead of using multiple push/pop layers for each frame.
      // However the run speed is fine for now.
      
      //Pre-spinning orientation.  Includes the wander effect.
      this.transform1.push();
      this.transform1.rotateY(Math.toRadians(orient));
      this.transform1.rotateZ(Math.toRadians(tilt));
      this.transform1.rotateZ(Math.toRadians(this.positionSpin));
      this.transform1.rotateZ(Math.toRadians(wanderLFO));
      //Wobble speed.
      this.transform1.push();
      this.transform1.rotateY(this.positionWobble);
      //WobbleWidth.
      this.transform1.push();
      this.transform1.rotateZ(wobbleWidthRadians);
      //Electron position, determined by electron velocity divided by elapsed time.
      this.transform1.push();
      this.transform1.rotateX(this.positionElectron);
      //Radius of electron's path
      this.transform1.push();
      this.transform1.translate(0, pRadius, 0);
          
      //Center of electron
      LXVector ePos = this.transform1.vector();

      //Draw tail 
      Iterator<Map.Entry<LXPoint, TailPoint>> tailIterator = this.tailPoints.entrySet().iterator();
      while(tailIterator.hasNext()) {
        Map.Entry<LXPoint, TailPoint> entry = tailIterator.next();
        double remainingPercent = (entry.getValue().endTime - this.parent.elapsedMs) / entry.getValue().lifeTime;
        if (remainingPercent <= 0) {
          //Tail point has exceeded lifetime.  Remove from collection.
          tailIterator.remove();
        } else {
          //Render tail with its original color, not the current color for that position.
          colors[entry.getKey().index] = LXColor.scaleBrightness(entry.getValue().c, (float)remainingPercent * MAX_TAIL_BRIGHTNESS);
        }
      }
      
      for (LXPoint p : model.points) {
            
        //Draw electron
        float distToElectron = dist(ePos, p);
        if (distToElectron<eSize) {
          
          //Point is within the electron
          //Fade the outer 10% to make a soft edge.
          float pointPercentile = (eSize - distToElectron) / eSize;
          float brightness = (pointPercentile > 0.1f) ? 100f : pointPercentile / 0.1f * 100f;
          int pointColor = palette.getColor(p, brightness); 
          colors[p.index] = pointColor;
          
          //Add point to list of TailPoints so it can be faded out gradually
          if (this.tailPoints.containsKey(p)) {
            TailPoint thisTailPoint = this.tailPoints.get(p);
            
            //Tailpoint is already lit.  But is it from this pass or did the electron catch its tail?          
            if (thisTailPoint.mostRecentFrame == this.previousFrame) {
              //Tailpoint is from this pass, ie it has never left electron.
              thisTailPoint.mostRecentFrame = this.previousFrame;
              //If it is closer to center than the last frame, then recalculate its lifetime to last longer.
              //This creates the tapered tail effect.
              if (distToElectron<thisTailPoint.distToElectron) {
                thisTailPoint.distToElectron = distToElectron;
                thisTailPoint.lifeTime = CalcTailLifetime(eSize, tailLength, distToElectron);
                thisTailPoint.endTime = this.parent.elapsedMs + thisTailPoint.lifeTime;
              }
            } else {
              //Tailpoint is from a previous pass.  Make a new one.
              TailPoint newTailPoint = new TailPoint(GetTailColor(pointColor, tailHueOffset), distToElectron, this.parent.elapsedMs, CalcTailLifetime(eSize, tailLength, distToElectron));
              this.tailPoints.put(p, newTailPoint);            
            }
          } else {
            //No tailpoint existed for this point.
              TailPoint newTailPoint = new TailPoint(GetTailColor(pointColor, tailHueOffset), distToElectron, this.parent.elapsedMs, CalcTailLifetime(eSize, tailLength, distToElectron));
              this.tailPoints.put(p, newTailPoint);
          }          
          
        } 
      }  
      
      //Undo all positioning except for original center location
      this.transform1.pop();
      this.transform1.pop();
      this.transform1.pop();
      this.transform1.pop();
      this.transform1.pop();
      
      //Track the previous frame for use in tapered tail calculations.
      //Use runMs as an ID for the frame.
      this.previousFrame = this.parent.elapsedMs;
    }
    
    protected int GetTailColor(int pointColor, float tailHueOffset) {
      return LXColor.hsb((LXColor.h(pointColor) + tailHueOffset) % 360, LXColor.s(pointColor), LXColor.b(pointColor));  
    }
    
    protected double CalcTailLifetime(float eSize, float tailLength, float distToElectron) {
      //Points closer to the center of the electron will have a longer lifetime.
      //This creates a tapered tail.
      return tailLength * 1000 * (eSize-distToElectron)/eSize;    
    }
    
  }
  
  
  private class TailPoint {
    protected int c;
    protected float distToElectron;
    protected double mostRecentFrame;
    protected double lifeTime;
    protected double endTime;
    
    TailPoint (int c, float distToElectron, double mostRecentFrame, double lifeTime) {
      this.c = c;
      this.distToElectron = distToElectron;
      this.mostRecentFrame = mostRecentFrame;
      this.lifeTime = lifeTime;
      this.endTime = mostRecentFrame + lifeTime;      
    }
  }
}