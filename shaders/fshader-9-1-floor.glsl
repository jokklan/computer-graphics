precision mediump float;

varying vec4 fColor;
varying vec2 fTexCoord;
varying vec4 fPositionFromLight;

uniform sampler2D texMap;
uniform sampler2D shadowMap;

void main() {
  gl_FragColor = vec4(fColor.rgb, 0.5) * texture2D(texMap, fTexCoord);
}
