#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;

in vec4 vertColor;
in vec4 vertTexCoord;

void main() {
  gl_FragColor = texture2D(texture, vertTexCoord.st) * vertColor;
  // gl_FragColor = vec4(1., 1., 1., 1.);
}
