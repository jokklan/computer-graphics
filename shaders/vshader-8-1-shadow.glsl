attribute vec4 vPosition;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
varying vec4 fColor;

void main() {
  gl_Position = projectionMatrix * modelViewMatrix * vPosition;
  fColor = vec4(0.0, 0.0, 0.0, 1.0);
}
