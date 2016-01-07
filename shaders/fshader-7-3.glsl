precision mediump float;

varying vec4 fColor;
varying vec2 fTexCoord;

uniform sampler2D texMap;

void main() {
  gl_FragColor = fColor * texture2D(texMap, fTexCoord);
}
