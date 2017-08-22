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

public class NoteWaves extends WavePattern {
  
  private final ADSR adsr = new ADSR();
  private final CompoundParameter attack = adsr.attack;
  private final CompoundParameter decay = adsr.decay;
  private final CompoundParameter sustain = adsr.sustain;
  private final CompoundParameter release = adsr.release;
  
  private final CompoundParameter velocityBrightness = new CompoundParameter("Vel>Brt", .5)
    .setDescription("Sets the amount of modulation from note velocity to brightness");
  
  private final NormalizedParameter level = new NormalizedParameter("level"); 
  
  private final ADSREnvelope envelope = new ADSREnvelope("Envelope", 0, this.level, this.attack, this.decay, this.sustain, this.release);
  
  private int notesDown = 0;
  private int damperNotes = 0;
  private boolean damperDown = false;
  
  public NoteWaves(LX lx) {
    super(lx);
    addParameter("attack", this.attack);
    addParameter("decay", this.decay);
    addParameter("sustain", this.sustain);
    addParameter("release", this.release);
    addParameter("velocityBrightness", this.velocityBrightness);
    addModulator(this.envelope);
  }
  
  public float getLevel() {
    return this.envelope.getValuef();
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
  private final float SPREAD = model.yRange / 31;
  
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
        float yp = model.cy + (note.pitch - 60 + note.bendDamped.getValuef() * Note.BEND_RANGE) * SPREAD;
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