// Object attributes
attribute vec4 vPosition;
attribute vec4 vColor;

// Object uniforms
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

// Fragment shader attributes
varying vec4 fColor;

void main() {
  gl_Position = projectionMatrix * modelViewMatrix * vPosition;
  fColor = vColor;
}
