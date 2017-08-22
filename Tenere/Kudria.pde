public class Breather extends TenerePattern {
  private final float E = exp(1);
  private final float SECOND = 1000;
  private final int COUNT = 100;

  public String getName() { return "Breather"; }
  public String getAuthor() { return "Benjamin Kudria"; }

  private double[] hues      = new double[lx.total];
  private SinLFO[] breathers = new SinLFO[COUNT];

  private BoundedParameter satParam  = new BoundedParameter("SAT", 90, 40, 100);
  private BoundedParameter huesParam = new BoundedParameter("HUES", 80, 30, 100);
  private BoundedParameter rateParam = new BoundedParameter("RATE", 10, 0.6, 15);
  private BoundedParameter varParam  = new BoundedParameter("VAR", 0.7, 0.1, 0.9);

  public Breather(LX lx) {
    super(lx);
    addParameter(satParam);
    addParameter(huesParam);
    addParameter(rateParam);
    addParameter(varParam);
    initBreathers();
    resetHues();
    breathe();
  }

  public double getRate() {
    float varianceRange = varParam.getValuef();
    float rate = rateParam.getValuef();
    float variance = random(-varianceRange, varianceRange) * rate;
    return (rate + variance) * SECOND;
  }

  private void initBreathers() {
    for (int p = 0; p < lx.total; p++) {
      int i = p % COUNT;
      breathers[i] = new SinLFO(-1, 1, getRate());
      breathers[i].setLooping(false);
      addModulator(breathers[i]).start();
    }
  }

  private void resetHues() {
    double startHue = random(0, 360);

    for (int p = 0; p < lx.total; p++) {
      double jitteredHue = startHue + random(-huesParam.getValuef(), huesParam.getValuef());
          if (jitteredHue < 0)   { hues[p] = 360 + jitteredHue; }
      else if (jitteredHue > 360) { hues[p] = jitteredHue - 360; }
      else                        { hues[p] = jitteredHue;      }
    }
  }

  public void resetBreathers() {
    for (int i = 0; i < COUNT; i++) {
      breathers[i].setPeriod(getRate());
      breathers[i].setBasis(random(0.02, 0.15));
      breathers[i].start();
    }
  }

  public void run(double deltaMs) {
    breathe();
  }

  public void breathe() {
    double maxBreath = 0;
    for (LXPoint p : model.points) {
      double breath = norm(-exp(breathers[p.index % COUNT].getValuef()), -1/E, -E);
      if (breath > maxBreath) { maxBreath = breath; }

      double brightness = breath * 80;
      colors[p.index] = LXColor.hsb(hues[p.index], satParam.getValue(), brightness);
    }

    if (maxBreath <= 0.001) {
      resetHues();
      resetBreathers();
    }
  }
}
