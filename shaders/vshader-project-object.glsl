// Object attributes
attribute vec4 vPosition;
attribute vec4 vColor;
attribute vec4 vNormal;

// Light attributes
const int NUM_LIGHTS = 3;
varying vec3 N;
varying vec3 L[NUM_LIGHTS];

// Object uniforms
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec4 lightPosition[NUM_LIGHTS];

// Fragment shader attributes
varying vec4 fColor;

void main() {
  // Calculate bject position
  vec3 pos = (modelViewMatrix * vPosition).xyz;

  // Calculate light position for each light
  for(int i=0; i < NUM_LIGHTS; i++) {
    vec3 lightPos = (modelViewMatrix * vec4(lightPosition[i].xyz, 1)).xyz;
    L[i] = normalize(pos - lightPos);
  }
  N = normalize((modelViewMatrix * vec4(-vNormal.xyz, 0)).xyz);

  // Set color and position
  fColor = vColor;
  gl_Position = projectionMatrix * modelViewMatrix * vPosition;
}
