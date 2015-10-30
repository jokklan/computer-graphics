precision mediump float;

varying vec4 fColor;
varying vec4 fNormal;

uniform sampler2D texMap;


float atan2(float y, float x) {
  return 2.0 * atan((length(vec2(x, y)) - x) / y);
}

void main() {
  float M_PI = 3.1415926535897932384626433832795;
  float x = fNormal.x;
  float y = fNormal.y;
  float z = fNormal.z;

  float phi = acos(y);
  float theta = atan2(z, x);

  float v = phi / (1.0 * M_PI);
  float u = theta / (2.0 * M_PI);

  vec2 fTexCoord = vec2(u, v);
  gl_FragColor = fColor * texture2D(texMap, fTexCoord);
}
