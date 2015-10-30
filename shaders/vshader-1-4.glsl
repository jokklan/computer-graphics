precision mediump float;

attribute vec4 vPosition;
varying vec4 fColor;
uniform float theta;

void main() {
  fColor = vec4( 1.0, 1.0, 1.0, 1.0 );
  gl_PointSize = 10.0;
  gl_Position.x = -sin(theta) * vPosition.x + cos(theta) * vPosition.y;
  gl_Position.y =  sin(theta) * vPosition.y + cos(theta) * vPosition.x;
  gl_Position.z = 0.0;
  gl_Position.w = 1.0;
}
