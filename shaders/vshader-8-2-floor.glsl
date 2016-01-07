attribute vec4 vPosition;
attribute vec4 vColor;
attribute vec2 vTexCoord;

uniform mat4 modelViewMatrix;
uniform mat4 modelViewMatrixFromLight;
uniform mat4 projectionMatrix;
uniform mat4 projectionMatrixFromLight;

varying vec4 fColor;
varying vec4 fPositionFromLight;
varying vec2 fTexCoord;

void main() {
  fColor = vColor;
  fPositionFromLight = projectionMatrixFromLight * modelViewMatrixFromLight * vPosition;
  fTexCoord = vTexCoord;
  gl_Position = projectionMatrix * modelViewMatrix * vPosition;
}
