import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2;

private static final int WOOD_FILL = #281403;
private static final int DUST_FILL = #A7784C;

public class UILogo extends UI3dComponent {
  private final PImage logoImage = loadImage("tenere.png");
  
  @Override
  protected void onDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
    // Logo
    float logoRadius = 4*FEET;
    float logoWidth = 6*FEET;
    float logoHeight = logoImage.height * logoWidth / logoImage.width;
    
    pg.translate(0, -Tree.LIMB_HEIGHT + logoHeight/2, -logoRadius+10*IN);
    pg.stroke(#191919);
    pg.fill(#000000);
    pg.box(logoWidth + 18*IN, logoHeight + 18*IN, 9*IN);
    pg.translate(0, Tree.LIMB_HEIGHT - logoHeight/2, logoRadius-10*IN);
    
    pg.noFill();
    pg.noStroke();
    pg.beginShape();
    pg.texture(logoImage);
    pg.textureMode(NORMAL);
    pg.tint(0x99ffffff);
    pg.vertex(-logoWidth/2, -Tree.LIMB_HEIGHT + logoHeight, -logoRadius, 0, 0);
    pg.vertex(logoWidth/2, -Tree.LIMB_HEIGHT + logoHeight, -logoRadius, 1, 0);
    pg.vertex(logoWidth/2, -Tree.LIMB_HEIGHT, -logoRadius, 1, 1);
    pg.vertex(-logoWidth/2, -Tree.LIMB_HEIGHT, -logoRadius, 0, 1);
    pg.endShape(CLOSE);
    pg.noTexture();
    pg.noTint();
  }
}

/**
 * Utility class for drawing cylinders. Assumes the cylinder is oriented with the
 * y-axis vertical. Use transforms to position accordingly.
 */
public static class UICylinder extends UI3dComponent {
  
  private final PVector[] base;
  private final PVector[] top;
  private final int detail;
  public final float len;
  
  public UICylinder(float radius, float len, int detail) {
    this(radius, radius, 0, len, detail);
  }
  
  public UICylinder(float baseRadius, float topRadius, float len, int detail) {
    this(baseRadius, topRadius, 0, len, detail);
  }
  
  public UICylinder(float baseRadius, float topRadius, float yMin, float yMax, int detail) {
    this.base = new PVector[detail];
    this.top = new PVector[detail];
    this.detail = detail;
    this.len = yMax - yMin;
    for (int i = 0; i < detail; ++i) {
      float angle = i * TWO_PI / detail;
      this.base[i] = new PVector(baseRadius * cos(angle), yMin, baseRadius * sin(angle));
      this.top[i] = new PVector(topRadius * cos(angle), yMax, topRadius * sin(angle));
    }
  }
  
  public void onDraw(UI ui, PGraphics pg) {
    pg.beginShape(TRIANGLE_STRIP);
    for (int i = 0; i <= this.detail; ++i) {
      int ii = i % this.detail;
      pg.vertex(this.base[ii].x, this.base[ii].y, this.base[ii].z);
      pg.vertex(this.top[ii].x, this.top[ii].y, this.top[ii].z);
    }
    pg.endShape(CLOSE);
  }
}

public class UITrunk extends UI3dComponent {
  
  private final UICylinder cylinder;
  private final PImage dust;
  private final PImage person;
  
  public UITrunk() {
    this.cylinder = new UICylinder(Tree.TRUNK_DIAMETER/2, Tree.TRUNK_DIAMETER/4, -Tree.LIMB_HEIGHT, 6*FEET, 8);
    this.dust = loadImage("dust.png");
    this.person = loadImage("person.png");
    addChild(this.cylinder);
  }
  
  @Override
  protected void onDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
    pg.tint(DUST_FILL);
    pg.textureMode(NORMAL);
    pg.beginShape();
    pg.texture(this.dust);
    pg.vertex(-100*FEET, -Tree.LIMB_HEIGHT - 1*FEET, -100*FEET, 0, 0);
    pg.vertex(100*FEET, -Tree.LIMB_HEIGHT - 1*FEET, -100*FEET, 0, 1);
    pg.vertex(100*FEET, -Tree.LIMB_HEIGHT - 1*FEET, 100*FEET, 1, 1);
    pg.vertex(-100*FEET, -Tree.LIMB_HEIGHT - 1*FEET, 100*FEET, 1, 0);
    pg.endShape(CLOSE);
    
    float personY = -Tree.LIMB_HEIGHT - 1*FEET;
    drawPerson(pg, -10*FEET, personY, 10*FEET, 1.5*FEET, 1.5*FEET);
    drawPerson(pg, 8*FEET, personY, 12*FEET, -1.5*FEET, 1.5*FEET);
    drawPerson(pg, 2*FEET, personY, 8*FEET, -2*FEET, 1*FEET);
    
    pg.fill(WOOD_FILL);
    pg.noStroke();
  }
  
  void drawPerson(PGraphics pg, float personX, float personY, float personZ, float personXW, float personZW) {
    pg.tint(#393939);
    pg.beginShape();
    pg.texture(this.person);
    pg.vertex(personX, personY, personZ, 0, 1);
    pg.vertex(personX + personXW, personY, personZ + personZW, 1, 1);
    pg.vertex(personX + personXW, personY + 5*FEET, personZ + personZW, 1, 0);
    pg.vertex(personX, personY + 5*FEET, personZ, 0, 0);
    pg.endShape(CLOSE);
  }
}

public class UISimulation extends UI3dComponent {
  UISimulation() {
    addChild(new UILogo());
    addChild(new UITrunk());
    addChild(uiTreeStructure = new UITreeStructure(tree));
  }
  
  protected void beginDraw(UI ui, PGraphics pg) {
    float level = 255;
    pg.pointLight(level, level, level, -10*FEET, 30*FEET, -30*FEET);
    pg.pointLight(level, level, level, 30*FEET, 20*FEET, -20*FEET);
    pg.pointLight(level, level, level, 0, 0, 30*FEET);
  }
  
  protected void endDraw(UI ui, PGraphics pg) {
    pg.noLights();
  }

}

public class UITreeStructure extends UI3dComponent {
  private final Tree tree;
  
  public UITreeStructure(Tree tree) {
    this.tree = tree;
    for (Limb limb : tree.limbs) {
      addChild(new UILimb(limb));
    }
    for (Branch branch : tree.branches) {
      if (branch.orientation != null) {
        addChild(new UIBranch(branch));
      }
    }
  }
 
}

public static class UILimb extends UI3dComponent {
    
  private final static UICylinder section1;
  private final static UICylinder section2;
  private final static UICylinder section3;
  private final static UICylinder section4;
  
  static {
    section1 = new UICylinder(Limb.SECTION_1.radius, Limb.SECTION_1.len, 5);
    section2 = new UICylinder(Limb.SECTION_2.radius, Limb.SECTION_2.len, 5);
    section3 = new UICylinder(Limb.SECTION_3.radius, Limb.SECTION_3.len, 5);
    section4 = new UICylinder(Limb.SECTION_4.radius, Limb.SECTION_4.len, 5);
  }
  
  private final float azimuth;
  private final float y;
  private final Limb.Size size;
  
  public UILimb(Limb limb) {
    this(limb.y, limb.azimuth, limb.size);
  }
  
  public UILimb(float azimuth, Limb.Size size) {
    this(0, azimuth, size);
  }
  
  public UILimb(float azimuth) {
    this(0, azimuth);
  }
  
  public UILimb(float y, float azimuth) {
    this(y, azimuth, Limb.Size.FULL);
  }
    
  public UILimb(float y, float azimuth, Limb.Size size) {
    this.y = y;
    this.azimuth = azimuth;
    this.size = size;
  }
  
  public void onDraw(UI ui, PGraphics pg) {
    pg.noStroke();
    pg.fill(WOOD_FILL);
    
    pg.pushMatrix();
    pg.translate(0, this.y, 0);
    pg.rotateY(HALF_PI - this.azimuth);
    pg.rotateX(HALF_PI - PI/12);
    
    if (this.size == Limb.Size.FULL) {
      section1.onDraw(ui, pg);
      pg.translate(0, section1.len, 0);
    }
    if (this.size != Limb.Size.SMALL) {
      section2.onDraw(ui, pg);
      pg.translate(0, section2.len, 0);
    }
    pg.rotateX(-PI/6);
    section3.onDraw(ui, pg);
    pg.translate(0, section3.len, 0);
    pg.rotateX(-PI/6);
    section4.onDraw(ui, pg);
    pg.popMatrix();
  }
}


public static class UIBranch extends UI3dComponent {

  private final Branch branch;
  
  private final static UICylinder cylinder;
  
  static {
    cylinder = new UICylinder(1*IN, .5*IN, 44*IN, 8);
  }
  
  public UIBranch(Branch branch) {
    this.branch = branch;
    for (LeafAssemblage assemblage : branch.assemblages) {
      addChild(new UILeafAssemblage(assemblage));
    }
        
  }
  
  @Override
  protected void beginDraw(UI ui, PGraphics pg) {
    pg.pushMatrix();
    pg.translate(this.branch.x, this.branch.y, this.branch.z);
    pg.rotateY(HALF_PI - this.branch.orientation.azimuth);
    pg.rotateX(HALF_PI - this.branch.orientation.elevation);
    pg.rotateY(this.branch.orientation.tilt);
  }
  
  @Override
  protected void onDraw(UI ui, PGraphics pg) {
    pg.fill(WOOD_FILL);
    pg.noStroke();
    cylinder.onDraw(ui, pg);
  }
  
  @Override
  protected void endDraw(UI ui, PGraphics pg) {
    pg.popMatrix();
  }
}

public static class UILeafAssemblage extends UI3dComponent {

  private final LeafAssemblage assemblage;
  private static final UICylinder cylinder;
  
  static {
    cylinder = new UICylinder(.4*IN, .4*IN, -12*IN, LeafAssemblage.LEAVES[8].y, 5);
  }

  public UILeafAssemblage(LeafAssemblage assemblage) {
    this.assemblage = assemblage;
  }
  
  @Override
  protected void beginDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
    pg.pushMatrix();
    pg.translate(this.assemblage.orientation.x, this.assemblage.orientation.y);
    pg.rotateZ(this.assemblage.orientation.theta);
    pg.rotateY(this.assemblage.orientation.tilt);
  }
  
  @Override
  protected void endDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
    pg.popMatrix();
  }
  
  @Override
  protected void onDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
    pg.fill(WOOD_FILL);
    pg.noStroke();
    cylinder.onDraw(ui, pg);
    
    // Now handled by UILeaves, left here for testing and/or reference...
    /*
    int[] colors = lx.getColors();
    for (Leaf leaf : this.assemblage.leaves) {
      pg.translate(leaf.position.x, leaf.position.y);
      pg.rotateZ(-leaf.position.theta);
      pg.rotateY(leaf.position.tilt);
      
      // Draw the leaf
      pg.tint(colors[leaf.points[0].index]);
      pg.textureMode(NORMAL);
      pg.beginShape(QUADS);
      pg.texture(LEAF_TEXTURE);
      pg.vertex(-Leaf.WIDTH/2, 0, 0, 1);
      pg.vertex(Leaf.WIDTH/2, 0, 1, 1);
      pg.vertex(Leaf.WIDTH/2, Leaf.LENGTH, 1, 0);
      pg.vertex(-Leaf.WIDTH/2, Leaf.LENGTH, 0, 0);
      pg.endShape(CLOSE);
      
      // Back to home base
      pg.rotateY(-leaf.position.tilt);
      pg.rotateZ(leaf.position.theta);
      pg.translate(-leaf.position.x, -leaf.position.y);
    }
    pg.noTint();
    */
  }
}

public class UILeaves extends UI3dComponent {
  
  protected final PImage texImage;
  
  public UILeaves() {
    this.texImage = loadImage("leaf.png");
  }
  
  @Override
  protected void onDraw(UI ui, PGraphics pg) {
    int[] colors = lx.getColors();    
    pg.noStroke();
    pg.noFill();
    pg.textureMode(NORMAL);
    pg.beginShape(QUADS);
    pg.texture(this.texImage);
    for (Leaf leaf : tree.leaves) {
      pg.tint(colors[leaf.points[0].index]);
      pg.vertex(leaf.coords[0].x, leaf.coords[0].y, leaf.coords[0].z, 0, 1);
      pg.vertex(leaf.coords[1].x, leaf.coords[1].y, leaf.coords[1].z, 0, 0);
      pg.vertex(leaf.coords[2].x, leaf.coords[2].y, leaf.coords[2].z, 1, 0);
      pg.vertex(leaf.coords[3].x, leaf.coords[3].y, leaf.coords[3].z, 1, 1);
    }
    pg.endShape(CLOSE);
    pg.noTexture();
    pg.noTint();
  }
}

// Faster version of UILeaves which uses PShape functionality to render
// with a faster shader using VBOs. Only the color buffer is pushed to the
// GPU on each frame.
public class UIShapeLeaves extends UILeaves {
  
  private LeafShape shape;
  
  class LeafShape extends PShapeOpenGL {
    
    private final IntBuffer tintBuffer;
    private final boolean BIG_ENDIAN =
      ByteOrder.nativeOrder() == ByteOrder.BIG_ENDIAN;
  
    LeafShape(PGraphics pg) {
      super((PGraphicsOpenGL) pg, PShape.GEOMETRY);
      set3D(true);
      
      setTexture(texImage);
      setTextureMode(NORMAL);
      setStroke(false);
      setFill(false);
      beginShape(QUADS);
      for (Leaf leaf : tree.leaves) {
        vertex(leaf.coords[0].x, leaf.coords[0].y, leaf.coords[0].z, 0, 1);
        vertex(leaf.coords[1].x, leaf.coords[1].y, leaf.coords[1].z, 0, 0);
        vertex(leaf.coords[2].x, leaf.coords[2].y, leaf.coords[2].z, 1, 0);
        vertex(leaf.coords[3].x, leaf.coords[3].y, leaf.coords[3].z, 1, 1);
      }
      endShape(CLOSE);
      markForTessellation();
      updateTessellation();
      initBuffers();
      
      this.tintBuffer = ByteBuffer
      .allocateDirect(tree.leaves.size() * 4 * Integer.SIZE / 8)
      .order(ByteOrder.nativeOrder())
      .asIntBuffer();
    }
    
    void updateColors(PGraphics pg, int[] colors) {
      // This is hacky as fuck! But couldn't find a better way to do this.
      // This reaches inside the PShapeOpenGL guts and updates ONLY the
      // vertex color buffer object with new data on each rendering pass.
      
      this.tintBuffer.rewind();
      if (BIG_ENDIAN) {
        for (int i = 0; i < colors.length; i += Leaf.NUM_LEDS) {
          int nativeARGB = (colors[i] >>> 24) | (colors[i] << 8);
          this.tintBuffer.put(nativeARGB);
          this.tintBuffer.put(nativeARGB);
          this.tintBuffer.put(nativeARGB);
          this.tintBuffer.put(nativeARGB);
        }
      } else {
        for (int i = 0; i < colors.length; i += Leaf.NUM_LEDS) {
          int rb = colors[i] & 0x00ff00ff;
          int nativeARGB = (colors[i] & 0xff00ff00) | (rb << 16) | (rb >> 16);
          this.tintBuffer.put(nativeARGB);
          this.tintBuffer.put(nativeARGB);
          this.tintBuffer.put(nativeARGB);
          this.tintBuffer.put(nativeARGB);
        }
      }
      this.tintBuffer.position(0);
      pgl.bindBuffer(PGL.ARRAY_BUFFER, bufPolyColor.glId);
      pgl.bufferData(PGL.ARRAY_BUFFER, tree.leaves.size() * 4 * Integer.SIZE/8, this.tintBuffer, PGL.STREAM_DRAW);
      pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);
    }
  }
    
  @Override
  protected void onDraw(UI ui, PGraphics pg) {
    if (this.shape == null) {
      this.shape = new LeafShape(pg);
    }
    this.shape.updateColors(pg, lx.getColors());
    pg.shape(this.shape);
  }
}

public class UITreeControls extends UICollapsibleSection {
  
  public final UIButton pointsVisible;
  public final UIButton leavesVisible;
  public final UIButton structureVisible;
  
  public UITreeControls(final LXStudio.UI ui) {
    super(ui, 0, 0, ui.leftPane.global.getContentWidth(), 200);
    setTitle("RENDER");
    setLayout(UI2dContainer.Layout.VERTICAL);
    setChildMargin(2);
    
    this.pointsVisible = (UIButton) new UIButton(0, 0, getContentWidth(), 18) {
      public void onToggle(boolean on) {
        ui.preview.pointCloud.setVisible(on);
      }
    }
    .setLabel("Points")
    .setActive(ui.preview.pointCloud.isVisible())
    .addToContainer(this);
    
    this.leavesVisible = (UIButton) new UIButton(0, 0, getContentWidth(), 18) {
      public void onToggle(boolean on) {
        uiLeaves.setVisible(on);
      }
    }
    .setLabel("Leaves")
    .setActive(uiLeaves.isVisible())
    .addToContainer(this);
    
    this.structureVisible = (UIButton) new UIButton(0, 0, getContentWidth(), 18) {
      public void onToggle(boolean on) {
        uiTreeStructure.setVisible(on);
      }
    }
    .setLabel("Structure")
    .setActive(uiTreeStructure.isVisible())
    .addToContainer(this);
  }
}

abstract class UIInput extends UI2dContainer {
  static final int PADDING = 4;
  static final int METER_Y = 26;
  static final int COLLAPSED_HEIGHT = 24;
  static final int HEIGHT = METER_Y + 2*PADDING + UISensorInput.HEIGHT;
  
  protected boolean expanded = false;
  
  private final UISensorInput uiInput;
  
  UIInput(UI ui, Sensors.Input input, float x, float y, float w) {
    super(x, y, w, COLLAPSED_HEIGHT);
    setBackgroundColor(ui.theme.getPaneBackgroundColor());
    setBorderRounding(4);
    
    this.uiInput = (UISensorInput) new UISensorInput(ui, input, PADDING, METER_Y, getContentWidth() - 2*PADDING).addToContainer(this);
    this.uiInput.setVisible(this.expanded);
  }
  
  public void onDraw(UI ui, PGraphics pg) {
    pg.noStroke();
    pg.fill(ui.theme.getControlTextColor());
    pg.beginShape();
    if (!this.expanded) {
      pg.vertex(this.width - PADDING - 2, 10);
      pg.vertex(this.width - PADDING - 8, 10);
      pg.vertex(this.width - PADDING - 5, 15);
    } else {
      pg.vertex(this.width - PADDING - 2, 14);
      pg.vertex(this.width - PADDING - 8, 14);
      pg.vertex(this.width - PADDING - 5, 9);
    }
    pg.endShape(CLOSE);
  }
  
  public void onMousePressed(MouseEvent mouseEvent, float mx, float my) {
    if (my < METER_Y && mx > this.width - 20) {
      this.expanded = !this.expanded;
      this.uiInput.setVisible(this.expanded);
      setContentHeight(this.expanded ? HEIGHT : COLLAPSED_HEIGHT);
    }
  }
}

public class UISensors extends UICollapsibleSection {
  
  final static int SENSOR_Y = 22;
  
  public UISensors(UI ui, Sensors sensors, float w) {
    super(ui, 0, 0, w, 0);
    setTitle("SENSORS");

    setLayout(UI2dContainer.Layout.VERTICAL);
    setChildMargin(2, 0);

    for (Sensors.Sensor sensor : sensors.sensor) {
      new UISensor(ui, sensor, 0, SENSOR_Y, getContentWidth())
      .addToContainer(this);
    }
  }
  
  class UISensor extends UIInput {
    UISensor(UI ui, final Sensors.Sensor sensor, float x, float y, float w) {
      super(ui, sensor.input, x, y, w);
            
      new UILabel(PADDING, 2*PADDING, 16, 16)
      .setLabel(sensor.getLabel())
      .setTextAlignment(PConstants.CENTER, PConstants.TOP)
      .addToContainer(this);
      
      new UIButton(24, PADDING, 16, 16)
      .setParameter(sensor.enabled)
      .addToContainer(this);
      
      new UIEnumBox(44, PADDING, getContentWidth() - 62, 16).setParameter(sensor.source).addToContainer(this);
    }
  }
}

public class UISources extends UICollapsibleSection {
  
  final static int SENSOR_Y = 22;
  final static int HEIGHT = 24 + SENSOR_Y + UISensorInput.HEIGHT;
  
  public UISources(UI ui, Sensors sensors, float w) {
    super(ui, 0, 0, w, HEIGHT);
    setTitle("SOURCES");
    
    setLayout(UI2dContainer.Layout.VERTICAL);
    setChildMargin(2, 0);
    
    for (Sensors.Source source : sensors.sources) {
      if (!source.isNull) {
        new UISource(ui, source, 0, 0, getContentWidth()).addToContainer(this);
      }
    }    
  }
  
  class UISource extends UIInput {
    UISource(UI ui, final Sensors.Source source, float x, float y, float w) {
      super(ui, source, x, y, w);
      
      new UILabel(PADDING, 2*PADDING, 100, 16)
      .setLabel(source.label)
      .setTextAlignment(PConstants.LEFT, PConstants.TOP)
      .addToContainer(this);
    }
  }
  
}

class UISensorInput extends UI2dContainer {
  
  static final int HEIGHT = 138;
  
  static final int METER_X = 20;
  static final int METER_MARGIN = 2;
  static final int METER_HEIGHT = 10;
  
  UISensorInput(UI ui, final Sensors.Input input, float x, float y, float w) {
    super(x, y, w, HEIGHT);
    y = 0;

    new UIImage(loadImage("heart.png"), 0, y) {
      public void onMousePressed(MouseEvent mouseEvent, float mx, float my) {
        input.heartBeat.setValue(true);
      }
    }.addToContainer(this);
    new UIParameterMeter(ui, input.heartLevel, METER_X, y, getContentWidth() - METER_X, 18).addToContainer(this);
    y += 18 + METER_MARGIN;
    
    new UIImage(loadImage("brain.png"), 0, y).addToContainer(this);
    for (NormalizedParameter p : input.eeg) {
      new UIParameterMeter(ui, p, METER_X, y, getContentWidth() - METER_X, METER_HEIGHT).addToContainer(this);
      y += METER_HEIGHT + METER_MARGIN;
    }
    
    new UIImage(loadImage("acc.png"), 0, y).addToContainer(this);
    for (NormalizedParameter p : input.acc) {
      new UIParameterMeter(ui, p, METER_X, y, getContentWidth() - METER_X, METER_HEIGHT).addToContainer(this);
      y += METER_HEIGHT + METER_MARGIN;
    }
    
    new UIImage(loadImage("gyro.png"), 0, y).addToContainer(this);
    for (NormalizedParameter p : input.gyro) {
      new UIParameterMeter(ui, p, METER_X, y, getContentWidth() - METER_X, METER_HEIGHT).addToContainer(this);
      y += METER_HEIGHT + METER_MARGIN;
    }
    
  }
}
  
class UIParameterMeter extends UI2dComponent implements UIModulationSource {
  
  private float level;
  private final LXNormalizedParameter parameter; 
  
  public UIParameterMeter(UI ui, final LXNormalizedParameter parameter, float x, float y, float w, float h) {
    super(x, y, w, h);
    setBackgroundColor(ui.theme.getControlBackgroundColor());
    setBorderColor(ui.theme.getControlBorderColor());
    this.parameter = parameter;
    this.level = parameter.getNormalizedf();
    addLoopTask(new LXLoopTask() {
      public void loop(double deltaMs) {
        float l2 = parameter.getNormalizedf();
        if (l2 != level) {
          level = l2;
          redraw();
        }
      }
    });
  }
  
  private void mouseValue(MouseEvent mouseEvent, float mx) {
    if (mouseEvent.isShiftDown() || mouseEvent.isMetaDown() || mouseEvent.isControlDown()) {
      parameter.setValue(mx / (this.width-1));
    }
  }
  protected void onMousePressed(MouseEvent mouseEvent, float mx, float my) {
    mouseValue(mouseEvent, mx);
  }
  
  protected void onMouseDragged(MouseEvent mouseEvent, float mx, float my, float dx, float dy) {
    mouseValue(mouseEvent, mx);
  }
  
  public void onDraw(UI ui, PGraphics pg) {
    pg.noStroke();
    pg.fill(ui.theme.getPrimaryColor());
    pg.rect(0, 0, getWidth() * this.level, getHeight());
  }
  
  public String getDescription() {
    return this.parameter.getDescription();
  }
  
  public LXNormalizedParameter getModulationSource() {
    return this.parameter.getComponent() != null ? this.parameter : null;
  }
}

public class UIOutputControls extends UICollapsibleSection {
  public UIOutputControls(final LXStudio.UI ui) {
    super(ui, 0, 0, ui.leftPane.global.getContentWidth(), 140);
    setTitle("OUTPUT");
        
    List<OutputItem> items = new ArrayList<OutputItem>();
    for (OPCDatagram datagram : datagrams) {
      items.add(new OutputItem(datagram));
    }
    UIItemList.ScrollList list =  new UIItemList.ScrollList(ui, 0, 0, getContentWidth(), getContentHeight());
    list.setShowCheckboxes(true);
    list.setItems(items);
    list.addToContainer(this);
  }
  
  class OutputItem extends UIItemList.AbstractItem {
    
    private final OPCDatagram datagram;
    
    public OutputItem(OPCDatagram datagram) {
      this.datagram = datagram;
    }
        
    public boolean isChecked() {
      return this.datagram.enabled.isOn();
    }
    
    public void onActivate() {
      this.datagram.enabled.toggle();
      redraw();
    }
    
    public void onCheck(boolean checked) {
      this.datagram.enabled.setValue(checked);
    }
        
    public String getLabel() {
      return String.format("%s/%d-%d", this.datagram.getAddress().getHostAddress(), this.datagram.getChannel(), this.datagram.getChannel()+3);
    }
  }
}