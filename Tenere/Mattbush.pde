public class Lattice extends LXPattern {

  public final CompoundParameter rippleRadius =
    new CompoundParameter("Ripple radius", 500, 50, 1000)
    .setDescription("Controls the spacing between ripples");

  public final CompoundParameter yFactor =
    new CompoundParameter("Y factor")
    .setDescription("How much Y is taken into account");

  public final CompoundParameter manhattanCoefficient =
    new CompoundParameter("Manh coeff")
    .setDescription("How much to use Manhattan vs Euclidean distance");


  private double timeSoFarMs = 0;

  public Lattice(LX lx) {
    super(lx);
    addParameter(rippleRadius);
    addParameter(yFactor);
    addParameter(manhattanCoefficient);
  }
  
  private double _calculateDistance(Leaf leaf) {
    double x = Math.abs(leaf.x);
    double y = (Math.abs(leaf.y) * this.yFactor.getValue());
    double z = Math.abs(leaf.z);
    
    double manhattanDistance = x + y + z;
    double euclideanDistance = Math.sqrt(x * x + y * y + z * z);
    return LXUtils.lerp(euclideanDistance, manhattanDistance, manhattanCoefficient.getValue());
  }

  public void run(double deltaMs) {
    timeSoFarMs += deltaMs;
    double tempoMs = 2000;
    double ticksSoFar = timeSoFarMs / tempoMs;

    double rippleRadius = this.rippleRadius.getValue();

    // Let's iterate over all the leaves...
    for (Leaf leaf : tree.leaves) {
      double totalDistance = _calculateDistance(leaf);
      double rawRefreshValue = totalDistance / rippleRadius;

      double refreshValue = (ticksSoFar - rawRefreshValue) % 1.0;
      // We can get the position of this point via p.x, p.y, p.z

      // Compute a brightness that dims as we move away from the line
      double brightness = 100 - refreshValue * 100;
      if (brightness > 0) {
        // There's a color here! Let's use the global color palette
        setColor(leaf, LXColor.gray((float) brightness));

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