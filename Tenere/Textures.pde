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

public class TextureNone extends TexturePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
 
  public TextureNone(LX lx) {
    super(lx);
    setColors(#ffffff);
  }
  
  public void run(double deltaMs) {}
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

public class TextureInOut extends TexturePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 1000, 5000, 200)
    .setExponent(.5)
    .setDescription("Speed of the motion");
    
  public final CompoundParameter size = (CompoundParameter)
    new CompoundParameter("Size", 2, 1, 4)
    .setDescription("Size of the streak");
  
  private final LXModulator[] leaves = new LXModulator[LeafAssemblage.NUM_LEAVES]; 
  private final int[] assemblageMask = new int[LeafAssemblage.NUM_LEDS];
  
  public TextureInOut(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("size", this.size);
    for (int i = 0; i < this.leaves.length; ++i) {
      final int ii = i;
      this.leaves[i] = startModulator(new SinLFO(0, (Leaf.NUM_LEDS-1)/2., new FunctionalParameter() {
        public double getValue() {
          return speed.getValue() * (1 + .05 * ii); 
        }
      }).randomBasis());
    }
  }
  
  public void run(double deltaMs) {
    int ai = 0;
    float falloff = 100 / this.size.getValuef();
    for (LXModulator leaf : this.leaves) {
      float pos = leaf.getValuef();
      for (int i = 0; i < Leaf.NUM_LEDS; ++i) {
        float d = abs(i - (LeafAssemblage.NUM_LEDS-1)/2.);       
        float b = max(0, 100 - falloff * abs(i - pos)); 
        this.assemblageMask[ai++] = LXColor.gray(b); 
      }
    }
    setAssemblageMask(this.assemblageMask);
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

public class TextureCrawl extends TexturePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  private static final int NUM_MASKS = 24;
  private final int[][] mask = new int[NUM_MASKS][Leaf.NUM_LEDS];
  
  private final LXModulator[] pos = new LXModulator[NUM_MASKS];
  private final LXModulator[] size = new LXModulator[NUM_MASKS];
  
  public TextureCrawl(LX lx) {
    super(lx);
    for (int i = 0; i < NUM_MASKS; ++i) {
      this.pos[i] = startModulator(new SawLFO(0, Leaf.NUM_LEDS, startModulator(new SinLFO(3000, 11000, 19000).randomBasis())));
      this.size[i] = startModulator(new TriangleLFO(-3, 2*Leaf.NUM_LEDS, 19000).randomBasis());
    }
  }
 
  public void run(double deltaMs) {
    for (int i = 0; i < NUM_MASKS; ++i) {
      float pos = this.pos[i].getValuef();
      float falloff = 100 / max(1, this.size[i].getValuef()); 
      for (int j = 0; j < Leaf.NUM_LEDS; ++j) {
        this.mask[i][j] = LXColor.gray(max(0, 100 - falloff * LXUtils.wrapdistf(j, pos, Leaf.NUM_LEDS)));
      }
    }
    int li = 0;
    for (Leaf leaf : model.leaves) {
      int[] mask = this.mask[li++ % NUM_MASKS];
      int i = 0;
      for (LXPoint p : leaf.points) {
        colors[p.index] = mask[i++];
      }
    }
  }
}


public class TextureWave extends TexturePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 1000, 4000, 250)
    .setDescription("Speed of oscillation between sides of the leaf")
    .setExponent(.5);
    
  private final LXModulator[] side = new LXModulator[LeafAssemblage.NUM_LEAVES];
  private final int[] assemblageMask = new int[LeafAssemblage.NUM_LEDS];
  
  public TextureWave(LX lx) {
    super(lx);
    for (int i = 0; i < this.side.length; ++i) {
      this.side[i] = startModulator(new SinLFO("Side", 0, 100, speed).setBasis(i / (float) this.side.length));
    }
    for (int i = 0; i < this.assemblageMask.length; ++i) {
      this.assemblageMask[i] = #000000;
    }
    addParameter("speed", this.speed);
  }
  
  public void run(double deltaMs) {
    int i = 0;
    for (int ai = 0; ai < LeafAssemblage.NUM_LEAVES; ++ai) {
      float side = this.side[ai].getValuef();
      for (int li = 0; li < Leaf.NUM_LEDS; ++li) {
        if (li < 3) {
          this.assemblageMask[i] = LXColor.gray(side);
        } else if (li > 3) {
          this.assemblageMask[i] = LXColor.gray(100 - side);
        }
        ++i;
      }
    }
    setAssemblageMask(this.assemblageMask);
  }
}