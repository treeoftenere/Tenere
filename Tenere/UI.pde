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

public class UIGLLeaves extends UILeaves {
  
  private PShader shader;
  // private final Texture texture;
  private final FloatBuffer vertexData;
  private int vertexBufferObjectName;
  private final int vertexBufferLengthBytes;
  private final static int STRIDE = 9;
  private final static int VERTICES_PER_LEAF = 6;
  
  public UIGLLeaves(LXStudio lx) {
    
    PGraphics pg = lx.ui.preview.getGraphics();
    pg.beginDraw();
    pg.endDraw();
    
    //pg.beginDraw();    
    //this.texImage.loadPixels();
    //this.texture = new Texture((PGraphicsOpenGL) pg, this.texImage.width, this.texImage.height);
    //this.texture.set(this.texImage.pixels, 0, 0, this.texImage.width, this.texImage.height, this.texImage.format);
    //pg.endDraw();
    
    loadShader();
    
    this.vertexBufferLengthBytes = tree.leaves.size() * VERTICES_PER_LEAF * STRIDE * Float.SIZE/8;
    
    this.vertexData = ByteBuffer
      .allocateDirect(vertexBufferLengthBytes)
      .order(ByteOrder.nativeOrder())
      .asFloatBuffer();
    
    this.vertexData.rewind();
    for (Leaf leaf : tree.leaves) {
      // Each leaf has two triangles
      putCoord(leaf, 0, 0, 1); // bottom-left
      putCoord(leaf, 1, 0, 0); // top-left
      putCoord(leaf, 2, 1, 0); // top-right
      putCoord(leaf, 0, 0, 1); // bottom-left
      putCoord(leaf, 3, 1, 0); // bottom-right
      putCoord(leaf, 2, 1, 0); // top-right
    }
    this.vertexData.position(0);
    
    // Generate a buffer binding
    PGL pgl = pg.beginPGL();
    IntBuffer resultBuffer = ByteBuffer
      .allocateDirect(1 * Integer.SIZE/8)
      .order(ByteOrder.nativeOrder())
      .asIntBuffer();
    pgl.genBuffers(1, resultBuffer); // Generates a buffer, places its id in resultBuffer[0]
    this.vertexBufferObjectName = resultBuffer.get(0); // Grab our buffer name
    pg.endPGL();
  }
  
  void putCoord(Leaf leaf, int coord, float s, float t) {
    // xyz coord
    this.vertexData.put(leaf.coords[coord].x);
    this.vertexData.put(leaf.coords[coord].y);
    this.vertexData.put(leaf.coords[coord].z);
    
    // texture s,t
    this.vertexData.put(s);
    this.vertexData.put(t);

    // color rgba
    this.vertexData.put(0f);
    this.vertexData.put(0f);
    this.vertexData.put(0f);
    this.vertexData.put(1f);
  }
  
  @Override
  protected void onUIResize(UI ui) {
    loadShader();
  }

  public void loadShader() {
    this.shader = applet.loadShader("LeafFragment.glsl", "LeafVertex.glsl");
  }
  
  @Override
  protected void onDraw(UI ui, PGraphics pg) {
    int[] colors = lx.getColors();
    // Put our new colors in the vertex data
    int i = 0;
    for (Leaf leaf : tree.leaves) {
      int c = colors[leaf.points[0].index];
      for (int j = 0; j < leaf.coords.length; ++j) {
        this.vertexData.put(STRIDE*i + 5, (0xff & (c >> 16)) / 255f); // R
        this.vertexData.put(STRIDE*i + 6, (0xff & (c >> 8)) / 255f); // G
        this.vertexData.put(STRIDE*i + 7, (0xff & (c)) / 255f); // B
        ++i;
      }
    }
    
    PGL pgl = pg.beginPGL();
    
    // Bind to our vertex buffer object, place the new color data
    pgl.bindBuffer(PGL.ARRAY_BUFFER, this.vertexBufferObjectName);
    pgl.bufferData(PGL.ARRAY_BUFFER, this.vertexBufferLengthBytes, this.vertexData, PGL.DYNAMIC_DRAW);
    
    this.shader.set("texture", this.texImage);
    this.shader.bind();
    int vertexLocation = pgl.getAttribLocation(this.shader.glProgram, "vertex");
    int texCoordLocation = pgl.getAttribLocation(this.shader.glProgram, "texCoord");
    int colorLocation = pgl.getAttribLocation(this.shader.glProgram, "color");
    pgl.enableVertexAttribArray(vertexLocation);
    pgl.enableVertexAttribArray(colorLocation);
    pgl.vertexAttribPointer(vertexLocation, 3, PGL.FLOAT, false, STRIDE * Float.SIZE/8, 0);
    pgl.vertexAttribPointer(texCoordLocation, 2, PGL.FLOAT, false, STRIDE * Float.SIZE/8, 3 * Float.SIZE/8);
    pgl.vertexAttribPointer(colorLocation, 4, PGL.FLOAT, false, STRIDE * Float.SIZE/8, 5 * Float.SIZE/8);
        
    // Draw the arrays
    pgl.drawArrays(PGL.TRIANGLES, 0, tree.leaves.size() * VERTICES_PER_LEAF);
    
    // Unbind
    pgl.disableVertexAttribArray(vertexLocation);
    pgl.disableVertexAttribArray(texCoordLocation);
    pgl.disableVertexAttribArray(colorLocation);
    // this.texture.unbind();
    this.shader.unbind();
    pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);
    
    // Done!
    pg.endPGL();
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