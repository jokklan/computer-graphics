precision mediump float;

varying vec4 fColor;
varying vec2 fTexCoord;
varying vec4 fPositionFromLight;

uniform sampler2D texMap;
uniform sampler2D shadowMap;

void main() {
  vec3 shadowCoord = (fPositionFromLight.xyz / fPositionFromLight.w) / 2.0 + 0.5;
  vec4 rgbaDepth = texture2D(shadowMap, shadowCoord.xy);
  float depth = rgbaDepth.r;
  float visibility = (shadowCoord.z > depth + 0.005) ? 0.7 : 1.0;
  vec4 color = texture2D(texMap, fTexCoord);
  gl_FragColor = vec4(color.rgb * visibility, color.a);
  //gl_FragColor = texture2D(shadowMap, shadowCoord.xy);
}
