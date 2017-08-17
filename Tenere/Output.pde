public static class TenereDatagram extends OPCDatagram {
  
  // TODO(mcslee): Tweak this value on-playa for best results
  static final float GAMMA = 1.8;
  
  static final byte[][] GAMMA_LUT = new byte[256][256];
  
  static {
    for (int b = 0; b < 256; ++b) {
      for (int in = 0; in < 256; ++in) {
        GAMMA_LUT[b][in] = (byte) (0xff & (int) Math.round(Math.pow(in * b / 65025.f, GAMMA) * 255.f));
      }
    }
  }
    
  private final LXParameter brightness; 
    
  public TenereDatagram(LX lx, int[] indices, byte channel) {
    super(indices, channel);
    this.brightness = lx.engine.output.brightness;
  }
  
  @Override
  protected LXDatagram copyPoints(int[] colors, int[] pointIndices, int offset) {
    final byte[] gamma = GAMMA_LUT[Math.round(255 * this.brightness.getValuef())];
    int i = offset;
    for (int index : pointIndices) {
      int c = (index >= 0) ? colors[index] : #000000;
      this.buffer[i    ] = gamma[0xff & (c >> 16)]; // R
      this.buffer[i + 1] = gamma[0xff & (c >> 8)]; // G
      this.buffer[i + 2] = gamma[0xff & c]; // B
      i += 3;
    }
    return this;
  }

}