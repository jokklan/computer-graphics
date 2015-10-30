precision mediump float;

attribute vec4 vPosition;
varying vec4 fColor;

void main() {
  fColor = vec4( 0.0, 0.0, 0.0, 1.0 );
  gl_PointSize = 10.0;
  gl_Position = vPosition;
}
