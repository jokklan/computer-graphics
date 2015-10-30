precision mediump float;

attribute vec4 vPosition;
attribute vec4 vColor;
varying vec4 fColor;

void main() {
  fColor = vColor;
  gl_PointSize = 10.0;
  gl_Position = vPosition;
}
