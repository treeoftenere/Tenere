public class MidiPattern extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  private final CompoundParameter attack = (CompoundParameter)
    new CompoundParameter("Attack", 50, 25, 1000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the attack time of the notes");
    
  private final CompoundParameter decay = (CompoundParameter)
    new CompoundParameter("Decay", 500, 50, 3000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the decay time of the notes");
    
  private final CompoundParameter sustain = (CompoundParameter)
    new CompoundParameter("Sustain", .5)
    .setExponent(2)
    .setDescription("Sets the sustain level of the notes");    
    
  private final CompoundParameter release = (CompoundParameter)
    new CompoundParameter("Release", 500, 50, 5000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the decay time of the notes");
  
  public static final int NUM_NOTE_LAYERS = 36;
  private final NoteLayer[] notes = new NoteLayer[NUM_NOTE_LAYERS];
  
  public MidiPattern(LX lx) {
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
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
  }
  
  class NoteLayer extends LXLayer {
    
    private final ADSREnvelope envelope = new ADSREnvelope("Env", 0, 1, attack, decay, sustain, release);  
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
    // noteLayer.velocity = note.getVelocity() / 127.;
    // noteLayer.level.setValue(lerp(100.f, noteLayer.velocity * 100, this.velocityBrightness.getNormalizedf()));
    noteLayer.envelope.engage.setValue(true);
  }
  
  @Override
  public void noteOffReceived(MidiNote note) {
    this.notes[note.getPitch() % NUM_NOTE_LAYERS].envelope.engage.setValue(false);
  }
}