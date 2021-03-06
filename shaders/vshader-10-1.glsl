attribute vec4 vPosition;
attribute vec4 vNormal;

varying vec4 fNormal;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

void main() {
  fNormal = vNormal;
  gl_Position = projectionMatrix * modelViewMatrix * vPosition;
}
