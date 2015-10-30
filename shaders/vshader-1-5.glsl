precision mediump float;

attribute vec4 vPosition;
varying vec4 fColor;
uniform float theta;

void main() {
  fColor = vec4( 1.0, 1.0, 1.0, 1.0 );
  gl_PointSize = 20.0;
  gl_Position.x = vPosition.x;
  gl_Position.y = sin(theta)/2.0 + vPosition.y;
  gl_Position.z = 0.0;
  gl_Position.w = 1.0;
}
