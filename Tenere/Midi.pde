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
  
  public static final int NUM_NOTE_LAYERS = 24;
  private final NoteLayer[] notes = new NoteLayer[NUM_NOTE_LAYERS];
  
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
    noteLayer.envelope.engage.setValue(true);
  }
  
  @Override
  public void noteOffReceived(MidiNote note) {
    this.notes[note.getPitch() % NUM_NOTE_LAYERS].envelope.engage.setValue(false);
  }
}

public class NoteWaves extends AudioWaves {
  
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
    if (--this.notesDown == 0) {
      this.envelope.release();
    }
  }
}