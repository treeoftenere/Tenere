public abstract class TexturePattern extends TenerePattern {
  public TexturePattern(LX lx) {
    super(lx);
  }
      
  protected void setLeafMask(int[] leafMask) { 
    for (Leaf leaf : model.leaves) {
      for (int i = 0; i < Leaf.NUM_LEDS; ++i) {
        colors[leaf.point.index + i] = leafMask[i];
      }
    }
  }
  
  protected void setAssemblageMask(int[] assemblageMask) {
    for (LeafAssemblage assemblage : model.assemblages) {
      for (int i = 0; i < assemblage.points.length; ++i) {
        colors[assemblage.points[i].index] = assemblageMask[i];
      }
    }
  }
  
  protected void setBranchMask(int[] branchMask) {
    for (Branch branch : model.branches) {
      for (int i = 0; i < branch.points.length; ++i) {
        colors[branch.points[i].index] = branchMask[i];
      }
    }
  }
}

public class TextureLoop extends TexturePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 500, 2000, 200)
    .setExponent(.5)
    .setDescription("Speed of the loop motion");    
  
  public final CompoundParameter size =
    new CompoundParameter("Size", 3, 1, Leaf.NUM_LEDS)
    .setDescription("Size of the thread");
  
  public LXModulator pos = startModulator(new SawLFO(0, Leaf.NUM_LEDS, speed)); 
  
  private final int[] leafMask = new int[Leaf.NUM_LEDS];
  
  public TextureLoop(LX lx) {
    super(lx);
    addParameter("rate", this.speed);
    addParameter("size", this.size);
  }
  
  public void run(double deltaMs) {
    float pos = this.pos.getValuef();
    float falloff = 100 / this.size.getValuef();
    for (int i = 0; i < this.leafMask.length; ++i) {
      this.leafMask[i] = LXColor.gray(max(0, 100 - falloff * LXUtils.wrapdistf(i, pos, Leaf.NUM_LEDS)));
    }
    setLeafMask(this.leafMask);
  }
}

public class TextureSparkle extends TexturePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  private final SinLFO[] levels = new SinLFO[LeafAssemblage.NUM_LEDS]; 
  
  private final int[] assemblageMask = new int[LeafAssemblage.NUM_LEDS];
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 1000, 5000, 200)
    .setExponent(.5)
    .setDescription("Speed of the sparkling");
    
  public final CompoundParameter bright = (CompoundParameter)
    new CompoundParameter("Bright", 60, 20, 100)
    .setDescription("Brightness of the sparkling");
  
  public TextureSparkle(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("bright", this.bright);
    for (int i = 0; i < this.levels.length; ++i) {
      this.levels[i] = new SinLFO(0, 0, 1000);
      initialize(this.levels[i]);
      startModulator(this.levels[i].randomBasis());
    }
  }
  
  private void initialize(SinLFO level) {
    level.setRange(0, random(this.bright.getValuef(), 100)).setPeriod(min(7000, speed.getValuef() * random(1, 2)));
  }
  
  public void run(double deltaMs) {
    for (int i = 0; i < this.levels.length; ++i) {
      if (this.levels[i].loop()) {
        initialize(this.levels[i]);
      }
      this.assemblageMask[i] = LXColor.gray(this.levels[i].getValuef());
    }
    setAssemblageMask(this.assemblageMask);
  }
}

public class TextureWave extends TexturePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 1000, 4000, 100)
    .setDescription("Speed of oscillation between sides of the leaf")
    .setExponent(.5);
    
  private final SinLFO side = (SinLFO) startModulator(new SinLFO("Side", 0, 100, speed));
  
  private final int[] leafMask = new int[Leaf.NUM_LEDS];
  
  public TextureWave(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    this.leafMask[3] = #000000;
  }
  
  public void run(double deltaMs) {
    float side = this.side.getValuef();
    for (int i = 0; i < Leaf.NUM_LEDS; ++i) {
      if (i < 3) {
        this.leafMask[i] = LXColor.gray(side);
      } else if (i > 3) {
        this.leafMask[i] = LXColor.gray(100 - side);
      }
    }
    setLeafMask(this.leafMask);
  }
}