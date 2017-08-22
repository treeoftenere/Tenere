public class Lattice extends LXPattern {

  public final CompoundParameter rippleRadius =
    new CompoundParameter("Ripple radius", 500.0, 50.0, 1000.0)
    .setDescription("Controls the spacing between ripples");

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

  private double timeSoFarMs = 100000;

  public Lattice(LX lx) {
    super(lx);
    addParameter(rippleRadius);
    addParameter(yFactor);
    addParameter(manhattanCoefficient);
    addParameter(triangleCoefficient);
    addParameter(visibleAmount);
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

    double rippleRadiusValue = rippleRadius.getValue();
    double triangleCoefficientValueHalf = triangleCoefficient.getValue() / 2;
    double visibleAmountValueMultiplier = 1 / visibleAmount.getValue();
    double visibleAmountValueToSubtract = visibleAmountValueMultiplier - 1;

    // Let's iterate over all the leaves...
    for (Leaf leaf : tree.leaves) {
      double totalDistance = _calculateDistance(leaf);
      double rawRefreshValue = totalDistance / rippleRadiusValue;

      double refreshValueModOne = (ticksSoFar - rawRefreshValue) % 1.0;
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