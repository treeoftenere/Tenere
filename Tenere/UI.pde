import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2;

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

public static class UITrunk extends UI3dComponent {
  @Override
  protected void onDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
    // MAJOR IMPROVEMENTS NEEDED HERE!
    // Quick hackup to draw a tree trunk.
    // Let's implement some shaders and have a nice simulation.
    pg.fill(#281403);
    pg.noStroke();
    pg.translate(0, -Tree.LIMB_HEIGHT/2, 0);
    pg.box(Tree.TRUNK_DIAMETER, Tree.LIMB_HEIGHT, Tree.TRUNK_DIAMETER);
    pg.translate(0, Tree.LIMB_HEIGHT/2, 0);
  }
}

public class UITreeStructure extends UI3dComponent {
  private final Tree tree;
  
  public UITreeStructure(Tree tree) {
    this.tree = tree;
    for (Branch branch : tree.branches) {
      addChild(new UIBranch(branch));
    }
  }
}

public class UIBranch extends UI3dComponent {

  private final Branch branch;
  
  private final static int CYLINDER_DETAIL = 8;
  private final PVector[] cylinderBase = new PVector[CYLINDER_DETAIL];
  private final PVector[] cylinderTop = new PVector[CYLINDER_DETAIL];
  
  public UIBranch(Branch branch) {
    this.branch = branch;
    for (LeafAssemblage assemblage : branch.assemblages) {
      addChild(new UILeafAssemblage(assemblage));
    }
    
    final float baseRadius = .75*IN;
    final float topRadius = .5*IN;
    for (int i = 0; i < CYLINDER_DETAIL; ++i) {
      float angle = i * TWO_PI / CYLINDER_DETAIL;
      cylinderBase[i] = new PVector(baseRadius * cos(angle), 0, baseRadius * sin(angle));
      cylinderTop[i] = new PVector(topRadius * cos(angle), 44*IN, topRadius * sin(angle));
    }
  }
  
  @Override
  protected void beginDraw(UI ui, PGraphics pg) {
    pg.pushMatrix();
    pg.rotateY(-this.branch.position.azimuth);
    pg.rotateZ(this.branch.position.elevation - HALF_PI);
    pg.rotateY(-this.branch.position.tilt);
    pg.translate(0, this.branch.position.radius);
  }
  
  @Override
  protected void onDraw(UI ui, PGraphics pg) {
    pg.fill(#999999);
    pg.noStroke();
    pg.beginShape(TRIANGLE_STRIP);
    for (int i = 0; i <= CYLINDER_DETAIL; ++i) {
      int ii = i % CYLINDER_DETAIL;
      pg.vertex(cylinderBase[ii].x, cylinderBase[ii].y, cylinderBase[ii].z);
      pg.vertex(cylinderTop[ii].x, cylinderTop[ii].y, cylinderTop[ii].z);
    }
    
    pg.endShape(CLOSE);
  }
  
  @Override
  protected void endDraw(UI ui, PGraphics pg) {
    pg.popMatrix();
  }
 
}

private PImage LEAF_TEXTURE;

public class UILeafAssemblage extends UI3dComponent {

  private final LeafAssemblage assemblage;
  
  public UILeafAssemblage(LeafAssemblage assemblage) {
    this.assemblage = assemblage;
    if (LEAF_TEXTURE == null) {
      LEAF_TEXTURE = loadImage("leaf.png");
    }
  }
  
  @Override
  protected void beginDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
    pg.pushMatrix();
    pg.translate(this.assemblage.position.x, this.assemblage.position.y);
    pg.rotateZ(-this.assemblage.position.theta);
    pg.rotateY(-this.assemblage.position.tilt);
  }
  
  @Override
  protected void endDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
    pg.popMatrix();
  }
  
  @Override
  protected void onDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
    
    final float stemWidth = .1*IN;
    pg.fill(#555555);
    pg.beginShape(QUADS);
    pg.vertex(-stemWidth, 0);
    pg.vertex(stemWidth, 0);
    pg.vertex(stemWidth, LeafAssemblage.LEAF_POSITIONS[8].y);
    pg.vertex(-stemWidth, LeafAssemblage.LEAF_POSITIONS[8].y);
    pg.endShape(CLOSE);
    
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
    private final PGL pgl;
    private final boolean BIG_ENDIAN =
      ByteOrder.nativeOrder() == ByteOrder.BIG_ENDIAN;
  
    LeafShape(PGraphics pg) {
      super((PGraphicsOpenGL) pg, PShape.GEOMETRY);
      set3D(true);
      this.pgl = ((PGraphicsOpenGL) pg).pgl;
      
      setTexture(texImage);
      setTextureMode(NORMAL);
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
        for (int i = 0; i < colors.length; ++i) {
          int nativeARGB = (colors[i] >>> 24) | (colors[i] << 8);
          this.tintBuffer.put(nativeARGB);
          this.tintBuffer.put(nativeARGB);
          this.tintBuffer.put(nativeARGB);
          this.tintBuffer.put(nativeARGB);
        }
      } else {
        for (int i = 0; i < colors.length; ++i) {
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
      pgl.bufferData(PGL.ARRAY_BUFFER, colors.length * 4 * Integer.SIZE/8, this.tintBuffer, PGL.STREAM_DRAW);
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
  
  public UITreeControls(final LXStudio.UI ui) {
    super(ui, 0, 0, ui.leftPane.global.getContentWidth(), 200);
    setTitle("RENDER");
    setLayout(UI2dContainer.Layout.VERTICAL);
    setChildMargin(2);
    
    new UIButton(0, 0, getContentWidth(), 18) {
      public void onToggle(boolean on) {
        ui.preview.pointCloud.setVisible(on);
      }
    }
    .setLabel("Points")
    .setActive(ui.preview.pointCloud.isVisible())
    .addToContainer(this);
    
    new UIButton(0, 0, getContentWidth(), 18) {
      public void onToggle(boolean on) {
        uiLeaves.setVisible(on);
      }
    }
    .setLabel("Leaves")
    .setActive(uiLeaves.isVisible())
    .addToContainer(this);
    
    new UIButton(0, 0, getContentWidth(), 18) {
      public void onToggle(boolean on) {
        uiTreeStructure.setVisible(on);
      }
    }
    .setLabel("Structure")
    .setActive(uiTreeStructure.isVisible())
    .addToContainer(this);
  }
}