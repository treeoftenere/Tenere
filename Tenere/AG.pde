import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import processing.opengl.PGraphics2D;

 


public class Turbulence extends LXPattern {
  // by Alexander Green 

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