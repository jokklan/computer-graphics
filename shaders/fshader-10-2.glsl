precision mediump float;

varying vec4 fTexCoords;
uniform samplerCube cubeSampler;

void main() {
  gl_FragColor = textureCube(cubeSampler, fTexCoords.xyz);
}
