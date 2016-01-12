precision mediump float;

varying vec4 fNormal;
uniform samplerCube cubeSampler;

void main() {
  gl_FragColor = textureCube(cubeSampler, fNormal.xyz);
}

