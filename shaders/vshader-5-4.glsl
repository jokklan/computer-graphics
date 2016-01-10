attribute vec4 vPosition;
attribute vec4 vColor;
attribute vec4 vNormal;
varying vec3 N, L, E;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec4 lightPosition;
varying vec4 color;

void main() {
  vec3 pos = (modelViewMatrix * vPosition).xyz;
  vec3 light = (modelViewMatrix * vec4(lightPosition.xyz, 1)).xyz;
  L = normalize(pos - light);
  E = normalize(-pos);
  N = normalize((modelViewMatrix * vec4(-vNormal.xyz, 0)).xyz);

  color = vColor;
  gl_Position = projectionMatrix * modelViewMatrix * vPosition;
}
