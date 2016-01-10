attribute vec4 vPosition;
attribute vec4 vColor;
attribute vec4 vNormal;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec4 lightPosition;
varying vec4 fColor;

void main() {
  vec3 light = (projectionMatrix * lightPosition).xyz;
  gl_Position = projectionMatrix * modelViewMatrix * vPosition;
  vec3 normal = normalize(vec3(projectionMatrix * vNormal));
  float nDotL = max(dot(normal, light), 0.0);
  fColor = vec4(vColor.rgb * nDotL, vColor.a);
}
