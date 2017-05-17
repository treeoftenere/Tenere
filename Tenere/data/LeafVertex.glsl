uniform mat4 transform;
uniform mat4 texMatrix;

attribute vec4 position;
attribute vec2 texCoord;
attribute vec4 color;

out vec4 vertColor;
out vec4 vertTexCoord;

void main() {
  gl_Position = transform * position;
    
  vertColor = color;
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
}
