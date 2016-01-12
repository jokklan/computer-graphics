attribute vec4 vPosition;

varying vec4 fTexCoords;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 Mtex;

void main() {
  fTexCoords = Mtex * vPosition;
  gl_Position = projectionMatrix * modelViewMatrix * vPosition;
}
