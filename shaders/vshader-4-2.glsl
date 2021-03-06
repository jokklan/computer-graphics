attribute  vec4 vPosition;
varying vec4 fColor;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

void main() {
    gl_Position = projectionMatrix * modelViewMatrix * vPosition;
    fColor = vec4((0.5+vPosition.xyz)/2.0, 1.0);
}
