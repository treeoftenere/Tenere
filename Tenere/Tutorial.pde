/**
 * Hi! Here is a super simple example of a pattern. This pattern draws
 * a horizontal line across the tree, which moves based upon a single
 * parameter and a modulator.
 *
 * This will introduce you to the basic building blocks of LX patterns,
 * which are parameters and modulators. Parameters have values. Basic ones
 * get exposed in the UI as knobs, so they're simple to control.
 *
 * Modulators are parameters that change value over time automatically.
 * The arguments to a modulator can be parameters, which means that you
 * can even chain modulators together for some wild results!
 *
 * Take a few minutes to play with this code 
 */
public class Tutorial extends LXPattern {

  // This is a parameter, it has a label, an intial value and a range 
  public final CompoundParameter yPos =
    new CompoundParameter("Pos", model.cy, model.yMin, model.yMax)
    .setDescription("Controls where the line is");

  public final CompoundParameter widthModulation =
    new CompoundParameter("Mod", 0, 8*FEET)
    .setDescription("Controls the amount of modulation of the width of the line");

  // This is a modulator, it changes values over time automatically
  public final SinLFO basicMotion = new SinLFO(
    -6*FEET, // This is a lower bound
    6*FEET, // This is an upper bound
    7000     // This is 3 seconds, 3000 milliseconds
    );

  public final SinLFO sizeMotion = new SinLFO(
    0, 
    widthModulation, // <- check it out, a parameter can be an argument to an LFO!
    13000
    );

  public Tutorial(LX lx) {
    super(lx);
    addParameter(yPos);
    addParameter(widthModulation);
    startModulator(basicMotion);
    startModulator(sizeMotion);
  }

  public void run(double deltaMs) {
    // The position of the line is a sum of the base position plus the motion
    double position = this.yPos.getValue() + this.basicMotion.getValue();
    double lineWidth = 2*FEET + sizeMotion.getValue();

    // Let's iterate over all the leaves...
    for (Leaf leaf : tree.leaves) {
      // We can get the position of this point via p.x, p.y, p.z

      // Compute a brightness that dims as we move away from the line 
      double brightness = 100 - (100/lineWidth) * Math.abs(leaf.y - position);
      if (brightness > 0) {
        // There's a color here! Let's use the global color palette
        setColor(leaf, palette.getColor(leaf.point, brightness));
        
        // Alternatively, if we wanted to do our own color scheme, we
        // could do a manual color computation:
        //   colors[p.index] = LX.hsb(hue[0-360], saturation[0-100], brightness[0-100])
        //   colors[p.index] = LX.rgb(red, green blue)
        //
        // Note that we do *NOT* use Processing's color() function. That
        // function employs global state and is not thread safe!
        
      } else {
        // This point is not even on! Best practice is to skip calling
        // the color palette if we don't need it, just set nothing.
        setColor(leaf, #000000);
      }
    }
  }
}

public class Plane extends LXPattern {
  
  public final CompoundParameter yPos = (CompoundParameter)
    new CompoundParameter("YPos", model.cy, model.yMin, model.yMax)
    .setDescription("Position of the plane on the Y-axis");
    
  public final CompoundParameter size = (CompoundParameter)
    new CompoundParameter("Size", 8*FT, 1*FT, 20*FT)
    .setDescription("Size of the plane");
  
  public Plane(LX lx) {
    super(lx);
    addParameter("yPos", this.yPos);
    addParameter("size", this.size);
  }
  
  public void run(double deltaMs) {
    float falloff = 100 / this.size.getValuef();
    float yPos = this.yPos.getValuef();
    for (Leaf leaf : tree.leaves) {
      float b = 100 - falloff * abs(leaf.y - yPos); 
      setColor(leaf, (b > 0) ? palette.getColor(leaf.point, b) : #000000);
    }
  }
}