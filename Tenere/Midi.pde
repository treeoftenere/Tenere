public class ADSR {
  final CompoundParameter attack = (CompoundParameter)
    new CompoundParameter("Attack", 50, 25, 1000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the attack time of the notes");
    
  final CompoundParameter decay = (CompoundParameter)
    new CompoundParameter("Decay", 500, 50, 3000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the decay time of the notes");
    
  final CompoundParameter sustain = (CompoundParameter)
    new CompoundParameter("Sustain", .5)
    .setExponent(2)
    .setDescription("Sets the sustain level of the notes");    
    
  final CompoundParameter release = (CompoundParameter)
    new CompoundParameter("Release", 500, 50, 5000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the decay time of the notes");
}

public class NoteAssemblages extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  private final ADSR adsr = new ADSR();
  private final CompoundParameter attack = adsr.attack;
  private final CompoundParameter decay = adsr.decay;
  private final CompoundParameter sustain = adsr.sustain;
  private final CompoundParameter release = adsr.release;
    
  private final CompoundParameter velocityBrightness = new CompoundParameter("Vel>Brt", .5)
    .setDescription("Sets the amount of modulation from note velocity to brightness");
  
  public static final int NUM_NOTE_LAYERS = 30;
  private final NoteLayer[] notes = new NoteLayer[NUM_NOTE_LAYERS];
  private boolean damperDown = false;
  
  public NoteAssemblages(LX lx) {
    super(lx);
    for (int i = 0; i < this.notes.length; ++i) {
      addLayer(this.notes[i] = new NoteLayer(lx));
    }
    int li = 0;
    for (LeafAssemblage assemblage : model.assemblages) {
      this.notes[li++ % this.notes.length].addFixture(assemblage);
    }
    addParameter("attack", this.attack);
    addParameter("decay", this.decay);
    addParameter("sustain", this.sustain);
    addParameter("release", this.release);
    addParameter("velocityBrightness", this.velocityBrightness);
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
  }
  
  class NoteLayer extends LXLayer {
    
    private NormalizedParameter level = new NormalizedParameter("Level", 1); 
    private final ADSREnvelope envelope = new ADSREnvelope("Env", 0, level, attack, decay, sustain, release);  
    private final List<LXFixture> fixtures = new ArrayList<LXFixture>();
    private boolean damper = false;
    
    NoteLayer(LX lx) {
      super(lx);
      addModulator(this.envelope);
    }
    
    void addFixture(LXFixture fixture) {
      this.fixtures.add(fixture);
    }
    
    public void run(double deltaMs) {
      int c = LXColor.gray(100 * this.envelope.getValue());
      for (LXFixture fixture : this.fixtures) {
        setColor(fixture, c);
      }
    }
  }
  
  @Override
  public void noteOnReceived(MidiNoteOn note) {
    NoteLayer noteLayer = this.notes[note.getPitch() % NUM_NOTE_LAYERS];
    noteLayer.level.setValue(lerp(1, note.getVelocity() / 127., this.velocityBrightness.getNormalizedf()));
    noteLayer.envelope.attack();
    noteLayer.damper = false;
  }
  
  @Override
  public void noteOffReceived(MidiNote note) {
    if (this.damperDown) {
      this.notes[note.getPitch() % NUM_NOTE_LAYERS].damper = true;
    } else {
      this.notes[note.getPitch() % NUM_NOTE_LAYERS].envelope.release();
    }
  }
  
  @Override
  public void controlChangeReceived(MidiControlChange cc) {
    if (cc.getCC() == MidiControlChange.DAMPER_PEDAL) {
      if (cc.getValue() > 0) {
        if (!this.damperDown) {
          this.damperDown = true;
          for (NoteLayer note : this.notes) {
            if (note.envelope.engage.isOn()) {
              note.damper = true;
            }
          }
        }
      } else {
        if (this.damperDown) {
          this.damperDown = false;
          for (NoteLayer note : this.notes) {
            if (note.damper) {
              note.envelope.engage.setValue(false);
            }
          }
        }
      }
    }
  }
}

public abstract class NoteWavePattern extends WavePattern {
  private final ADSR adsr = new ADSR();
  public final CompoundParameter attack = adsr.attack;
  public final CompoundParameter decay = adsr.decay;
  public final CompoundParameter sustain = adsr.sustain;
  public final CompoundParameter release = adsr.release;
  
  public final CompoundParameter velocityBrightness = new CompoundParameter("Vel>Brt", .5)
    .setDescription("Sets the amount of modulation from note velocity to brightness");
  
  protected final NormalizedParameter level = new NormalizedParameter("level"); 
  
  protected final ADSREnvelope envelope = new ADSREnvelope("Envelope", 0, this.level, this.attack, this.decay, this.sustain, this.release);
  
  private int notesDown = 0;
  private int damperNotes = 0;
  private boolean damperDown = false;
  
  protected NoteWavePattern(LX lx) {
    super(lx);
    addParameter("attack", this.attack);
    addParameter("decay", this.decay);
    addParameter("sustain", this.sustain);
    addParameter("release", this.release);
    addParameter("velocityBrightness", this.velocityBrightness);
    addModulator(this.envelope);
  }
  
  @Override
  public void noteOnReceived(MidiNoteOn note) {
    ++this.notesDown;
    this.level.setValue(note.getVelocity() / 127.);
    this.envelope.attack();
    
  }
  
  @Override
  public void noteOffReceived(MidiNote note) {
    if (this.damperDown) {
      ++this.damperNotes;
    } else {
      if (--this.notesDown == 0) {
        this.envelope.release();
      }
    }
  }
    
  @Override
  public void controlChangeReceived(MidiControlChange cc) {
    if (cc.getCC() == MidiControlChange.DAMPER_PEDAL) {
      if (cc.getValue() > 0) {
        if (!this.damperDown) {
          this.damperDown = true;
        }
      } else {
        if (this.damperDown) {
          this.damperDown = false;
          this.notesDown -= this.damperNotes;
          this.damperNotes = 0;
          if (this.notesDown == 0) {
            this.envelope.release();
          }
        }
      }
    }
  }
  
  public float getLevel() {
    return this.envelope.getValuef();
  }
}

public class NoteWaves extends NoteWavePattern {
  
  public NoteWaves(LX lx) {
    super(lx);
  }
 

}

public abstract class NoteMelt extends NoteWavePattern {
  
  private final float[] multipliers = new float[32];

  public final CompoundParameter melt =
    new CompoundParameter("Melt", .5)
    .setDescription("Amount of melt distortion");
  
  private final LXModulator meltDamped = startModulator(new DampedParameter(this.melt, 2, 2, 1.5));
  
  private final LXModulator rot = startModulator(new SawLFO(0, 1, 39000));
    
  public NoteMelt(LX lx) {
    super(lx);
    addParameter("melt", this.melt);
    for (int i = 0; i < this.multipliers.length; ++i) {
      float r = random(.6, 1);
      this.multipliers[i] = r * r * r;
    }
  }
  
  public void onRun(double deltaMs) {
    float speed = this.speed.getValuef();
    float rot = this.rot.getValuef();
    float melt = this.meltDamped.getValuef();
    for (Leaf leaf : model.leaves) {
      float az = leaf.point.azimuth;
      float maz = (az / TWO_PI + rot) * this.multipliers.length;
      float lerp = maz % 1;
      int floor = (int) (maz - lerp);
      float m = lerp(1, lerp(this.multipliers[floor % this.multipliers.length], this.multipliers[(floor + 1) % this.multipliers.length], lerp), melt);      
      float d = getDist(leaf);
      int offset = round(d * speed * m);
      setColor(leaf, this.history[(this.cursor + offset) % this.history.length]);
    }
  }
  
  protected abstract float getDist(Leaf leaf);
  
}

public class NoteMeltOut extends NoteMelt {
  public NoteMeltOut(LX lx) {
    super(lx);
  }
  
  protected float getDist(Leaf leaf) {
    return 2*abs(leaf.point.yn - .5);
  }
}

public class NoteMeltUp extends NoteMelt {
  public NoteMeltUp(LX lx) {
    super(lx);
  }
  
  protected float getDist(Leaf leaf) {
    return leaf.point.yn;
  }
}

public class NoteMeltDown extends NoteMelt {
  public NoteMeltDown(LX lx) {
    super(lx);
  }
  
  protected float getDist(Leaf leaf) {
    return 1 - leaf.point.yn;
  }
}

public class NotePulse extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  private final ADSR adsr = new ADSR();
  private final CompoundParameter attack = adsr.attack;
  private final CompoundParameter decay = adsr.decay;
  private final CompoundParameter sustain = adsr.sustain;
  private final CompoundParameter release = adsr.release;
    
  private final CompoundParameter velocityBrightness = new CompoundParameter("Vel>Brt", .5)
    .setDescription("Sets the amount of modulation from note velocity to brightness");

  private NormalizedParameter level = new NormalizedParameter("Level", 1); 
  private final ADSREnvelope envelope = new ADSREnvelope("Env", 0, this.level, this.attack, this.decay, this.sustain, this.release);
  
  public NotePulse(LX lx) {
    super(lx);
    addParameter("attack", this.attack);
    addParameter("decay", this.decay);
    addParameter("sustain", this.sustain);
    addParameter("release", this.release);
    addParameter("velocityBrightness", this.velocityBrightness);
    addModulator(this.envelope);
  }
  
  public void run(double deltaMs) {
    setColors(LXColor.gray(100 * this.envelope.getValuef()));
  }
  
  @Override
  public void noteOnReceived(MidiNoteOn note) {
    this.level.setValue(lerp(1, note.getVelocity() / 127., this.velocityBrightness.getNormalizedf()));
    this.envelope.engage.setValue(true);
  }
  
  @Override
  public void noteOffReceived(MidiNote note) {
    this.envelope.engage.setValue(false);
  }
}

public class NoteSnakes extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  final static int NUM_BRANCH_GROUPS = 24;
  
  private final LinearEnvelope[] branchGroups = new LinearEnvelope[NUM_BRANCH_GROUPS];
  private final int[][] branchMasks = new int[NUM_BRANCH_GROUPS][Branch.NUM_LEAVES];
  
  public final CompoundParameter speed =
    new CompoundParameter("Speed", 2000, 10000, 500)
    .setDescription("Speed of the snakes"); 
  
  public final CompoundParameter size =
    new CompoundParameter("Size", 10, 5, 80)
    .setDescription("Size of the snakes"); 
  
  private int branchRoundRobin = 0;
  
  public NoteSnakes(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("size", this.size);
    for (int i = 0; i < this.branchGroups.length; ++i) {
      this.branchGroups[i] = (LinearEnvelope) addModulator(new LinearEnvelope(0, Branch.NUM_LEAVES + 40, speed));
    }
  }
  
  public void run(double deltaMs) {
    float falloff = 100 / this.size.getValuef();
    for (int i = 0; i < NUM_BRANCH_GROUPS; ++i) {
      int[] mask = this.branchMasks[i];
      float pos = this.branchGroups[i].getValuef();
      float max = 100 * (1 - this.branchGroups[i].getBasisf());
      for (int j = 0; j < Branch.NUM_LEAVES; ++j) {
        float b = (j < pos) ? max(0, 100 - falloff * (pos - j)) : 0;
        mask[j] = LXColor.gray(b); 
      }
    }
    
    // Copy into all masks
    int bi = 0;
    for (Branch branch : model.branches) {
      int li = 0;
      for (Leaf leaf : branch.leaves) {
        setColor(leaf, this.branchMasks[bi % this.branchMasks.length][li]);
        ++li;
      }
      ++bi;
    }
  }
  
  @Override
  public void noteOnReceived(MidiNoteOn note) {
    this.branchGroups[this.branchRoundRobin].trigger();
    this.branchRoundRobin = (this.branchRoundRobin + 1) % this.branchGroups.length;
  }
}

public class NoteSeaboard extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter attack = (CompoundParameter)
    new CompoundParameter("Attack", 50, 25, 1000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the attack time of the notes");
    
  public final CompoundParameter decay = (CompoundParameter)
    new CompoundParameter("Decay", 500, 50, 3000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the decay time of the notes");
    
  public final CompoundParameter size =
    new CompoundParameter("Size", 2*FEET, 1*FEET, 8*FEET)
    .setDescription("Size of the notes");

  private final Note[] notes = new Note[16];
  private final Note[] channelToNote = new Note[16];
  private int noteRoundRobin = 0;
  
  public NoteSeaboard(LX lx) {
    super(lx);
    addParameter("attack", this.attack);
    addParameter("decay", this.decay);
    addParameter("size", this.size);
    for (int i = 0; i < this.notes.length; ++i) {
      this.channelToNote[i] = this.notes[i] = new Note();
    }
  }
  
  private final float[] b = new float[model.assemblages.size()];
  
  private final int NUM_KEYS = 25;
  private final int CENTER_KEY = 60;
  
  private final float SPREAD = model.yRange / (NUM_KEYS + 6);
  
  public void run(double deltaMs) {
    for (int i = 0; i < b.length; ++i) {
      b[i] = 0;
    }
    float size = this.size.getValuef();
    
    // Iterate over each note
    for (Note note : this.notes) {
      float level = note.levelDamped.getValuef() * note.envelope.getValuef();
      if (level > 0) {
        float falloff = 100 / (size * (1 + 2 * note.slideDamped.getValuef()));
        int i = 0;
        float yp = model.cy + (note.pitch - CENTER_KEY + note.bendDamped.getValuef() * Note.BEND_RANGE) * SPREAD;
        for (LeafAssemblage assemblage : model.assemblages) {
          b[i] += max(0, level - falloff * abs(yp - assemblage.points[0].y));
          ++i;
        }
      }
    }
    
    // Set colors for a
    int i = 0;
    for (LeafAssemblage assemblage : model.assemblages) {
      setColor(assemblage, LXColor.gray(min(100, b[i++])));
    }
  }
  
  class Note {
    
    static final float BEND_RANGE = 48;
        
    private final NormalizedParameter level = new NormalizedParameter("Level");
    private final NormalizedParameter slide = new NormalizedParameter("Slide");
    private final BoundedParameter bend = new BoundedParameter("Bend", 0, -1, 1);

    final LXModulator bendDamped = startModulator(new DampedParameter(this.bend, .3, 1, .1));
    final LXModulator slideDamped = startModulator(new DampedParameter(this.slide, .3, 1));
    final LXModulator levelDamped = startModulator(new DampedParameter(this.level, .4));

    final ADEnvelope envelope = new ADEnvelope("Note", 0, 100, attack, decay);
        
    int pitch;
    
    Note() {
      addModulator(envelope);      
    }
  }
    
  @Override
  public void noteOnReceived(MidiNoteOn note) {
    this.channelToNote[note.getChannel()] = this.notes[this.noteRoundRobin];
    this.noteRoundRobin = (this.noteRoundRobin + 1) % 16; 
    
    Note n = this.channelToNote[note.getChannel()];
    n.bend.setValue(0);
    n.bendDamped.setValue(0);
    n.slide.setValue(0);
    n.slideDamped.setValue(0);
    n.pitch = note.getPitch();
    n.level.setValue(note.getVelocity() / 127.f);
    n.levelDamped.setValue(note.getVelocity() / 127.f);
    n.envelope.engage.setValue(true);
  }
  
  @Override
  public void noteOffReceived(MidiNote note) {
    Note n = this.channelToNote[note.getChannel()];
    n.level.setValue(n.levelDamped.getValue());
    n.envelope.engage.setValue(false);
  }
  
  @Override
  void aftertouchReceived(MidiAftertouch aftertouch) {
    // Wait until note attack stage is done...
    Note n = this.channelToNote[aftertouch.getChannel()];
    if (!n.envelope.isRunning()) {
      n.level.setValue(aftertouch.getAftertouch() / 127.f);
    }
  }
  
  @Override
  public void pitchBendReceived(MidiPitchBend pb) {
    this.channelToNote[pb.getChannel()].bend.setValue(pb.getNormalized());
  }
  
  @Override
  public void controlChangeReceived(MidiControlChange cc) {
    if (cc.getCC() == 74) {
      this.channelToNote[cc.getChannel()].slide.setValue(cc.getNormalized());
    }
  }
}