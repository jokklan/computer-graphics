attribute vec4 vPosition;
attribute vec4 vNormal;
varying vec3 N, L, E;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec4 lightPosition;

void main() {
  vec3 pos = (modelViewMatrix * vPosition).xyz;
  vec3 light = (modelViewMatrix * vec4(lightPosition.xyz,1)).xyz;
  L = normalize(light - pos);
  E = normalize(-pos);
  N = normalize((modelViewMatrix * vec4(-vNormal.xyz, 0)).xyz);

  gl_Position = projectionMatrix * modelViewMatrix * vPosition;
}
