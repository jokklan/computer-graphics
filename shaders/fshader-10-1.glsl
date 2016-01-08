precision mediump float;

varying vec4 fColor;
varying vec4 fNormal;
varying vec3 R;

uniform samplerCube cubeSampler;

void main() {
  gl_FragColor = textureCube(cubeSampler, fNormal.xyz);
}
