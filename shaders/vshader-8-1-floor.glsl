attribute vec4 vPosition;
attribute vec4 vColor;
attribute vec2 vTexCoord;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

varying vec4 fColor;
varying vec2 fTexCoord;

void main() {
  fColor = vColor;
  fTexCoord = vTexCoord;
  gl_Position = projectionMatrix * modelViewMatrix * vPosition;
}
