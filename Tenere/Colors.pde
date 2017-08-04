public class ColorSpread extends LXPattern {
  
  public ColorSpread(LX lx) {
    super(lx);
  }
  
  public void run(double deltaMs) {
    float hue = palette.getHuef();
    float sat = palette.getSaturationf();
    float spreadX = palette.spreadX.getValuef();
    float spreadY = palette.spreadY.getValuef();
    float spreadZ = palette.spreadZ.getValuef();
    float offsetX = palette.offsetX.getValuef();
    float offsetY = palette.offsetY.getValuef();
    float offsetZ = palette.offsetZ.getValuef();
    boolean mirror = palette.mirror.isOn();
    for (Leaf leaf : tree.leaves) {
      float dx = leaf.point.xn - .5 - offsetX;
      float dy = leaf.point.yn - .5 - offsetY;
      float dz = leaf.point.zn - .5 - offsetZ;
      if (mirror) {
        dx = abs(dx);
        dy = abs(dy);
        dz = abs(dz);
      }
      setColor(leaf, LXColor.hsb(
        hue + spreadX*dx + spreadY*dy + spreadZ*dz,
        sat,
        100
      ));
    }
  }
}