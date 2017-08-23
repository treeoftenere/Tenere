public class Lattice extends LXPattern {

  public final double MAX_RIPPLES_TREAT_AS_INFINITE = 2000.0;
  
  public final CompoundParameter rippleRadius =
    new CompoundParameter("Ripple radius", 500.0, 200.0, MAX_RIPPLES_TREAT_AS_INFINITE)
    .setDescription("Controls the spacing between ripples");

  public final CompoundParameter subdivisionSize =
    new CompoundParameter("Subdivision size", MAX_RIPPLES_TREAT_AS_INFINITE, 200.0, MAX_RIPPLES_TREAT_AS_INFINITE)
    .setDescription("Subdivides the canvas into smaller canvases of this size");

  public final CompoundParameter numSpirals =
    new CompoundParameter("Spirals", 0, -3, 3)
    .setDescription("Adds a spiral effect");

  public final CompoundParameter yFactor =
    new CompoundParameter("Y factor")
    .setDescription("How much Y is taken into account");

  public final CompoundParameter manhattanCoefficient =
    new CompoundParameter("Square")
    .setDescription("Whether the rippes should be circular or square");

  public final CompoundParameter triangleCoefficient =
    new CompoundParameter("Triangle coeff")
    .setDescription("Whether the wave resembles a sawtooth or a triangle");

  public final CompoundParameter visibleAmount =
    new CompoundParameter("Visible", 1.0, 0.1, 1.0)
    .setDescription("Whether the full wave is visible or only the peaks");

  public Lattice(LX lx) {
    super(lx);
    addParameter(rippleRadius);
    addParameter(subdivisionSize);
    addParameter(numSpirals);
    addParameter(yFactor);
    addParameter(manhattanCoefficient);
    addParameter(triangleCoefficient);
    addParameter(visibleAmount);
  }
  
  private double _modAndShiftToHalfZigzag(double dividend, double divisor) {
    double mod = (dividend + divisor) % divisor;
    double value = (mod > divisor / 2) ? (mod - divisor) : mod;
    int quotient = (int) (dividend / divisor);
    return (quotient % 2 == 0) ? -value : value;
  }
  
  private double _calculateDistance(Leaf leaf) {
    double x = leaf.x;
    double y = leaf.y * this.yFactor.getValue();
    double z = leaf.z;
    
    double subdivisionSizeValue = subdivisionSize.getValue();
    if (subdivisionSizeValue < MAX_RIPPLES_TREAT_AS_INFINITE) {
      x = _modAndShiftToHalfZigzag(x, subdivisionSizeValue);
      y = _modAndShiftToHalfZigzag(y, subdivisionSizeValue);
      z = _modAndShiftToHalfZigzag(z, subdivisionSizeValue);
    }
        
    double manhattanDistance = (Math.abs(x) + Math.abs(y) + Math.abs(z)) / 1.5;
    double euclideanDistance = Math.sqrt(x * x + y * y + z * z);
    return LXUtils.lerp(euclideanDistance, manhattanDistance, manhattanCoefficient.getValue());
  }

  public void run(double deltaMs) {
    // add an arbitrary number of beats so refreshValueModOne isn't negative;
    // divide by 4 so you get one ripple per measure
    double ticksSoFar = (lx.tempo.beatCount() + lx.tempo.ramp() + 256) / 4;

    double rippleRadiusValue = rippleRadius.getValue();
    double triangleCoefficientValueHalf = triangleCoefficient.getValue() / 2;
    double visibleAmountValueMultiplier = 1 / visibleAmount.getValue();
    double visibleAmountValueToSubtract = visibleAmountValueMultiplier - 1;
    double numSpiralsValue = Math.round(numSpirals.getValue());

    // Let's iterate over all the leaves...
    for (Leaf leaf : tree.leaves) {
      double totalDistance = _calculateDistance(leaf);
      double rawRefreshValueFromDistance = totalDistance / rippleRadiusValue;
      double rawRefreshValueFromSpiral = Math.atan2(leaf.z, leaf.x) * numSpiralsValue / (2 * Math.PI);

      double refreshValueModOne = (ticksSoFar - rawRefreshValueFromDistance - rawRefreshValueFromSpiral) % 1.0;
      double brightnessValueBeforeVisibleCheck = (refreshValueModOne >= triangleCoefficientValueHalf) ?
        1 - (refreshValueModOne - triangleCoefficientValueHalf) / (1 - triangleCoefficientValueHalf) :
        (refreshValueModOne / triangleCoefficientValueHalf);

      double brightnessValue = brightnessValueBeforeVisibleCheck * visibleAmountValueMultiplier - visibleAmountValueToSubtract;

      if (brightnessValue > 0) {
        setColor(leaf, LXColor.gray((float) brightnessValue * 100));
      } else {
        setColor(leaf, #000000);
      }
    }
  }
}