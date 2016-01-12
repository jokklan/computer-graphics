precision mediump float;

varying vec3 N;
varying vec4 fColor;

const int NUM_LIGHTS = 6;
varying vec3 L[NUM_LIGHTS];

uniform vec4 ambientProduct;
uniform vec4 materialDiffuse;
uniform vec4 lightDiffuse[NUM_LIGHTS];

void main() {
  vec4 finalColor = vec4(0.0, 0.0, 0.0, 1.0);

  for(int i = 0; i < NUM_LIGHTS; i++) {
    vec3 currentL = L[i];

    float Kd = max(dot(currentL, N), 0.0);
    vec4  diffuse = Kd * materialDiffuse * lightDiffuse[i];

    finalColor += diffuse;
  }

  finalColor += ambientProduct;

  finalColor.a = 1.0;
  gl_FragColor = finalColor;
}
