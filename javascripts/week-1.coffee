---
---
window.onload = ->
  # Part 1
  gl = setupCanvas('part_1')

  pointsTriangle = [
    vec2(1, 1),
    vec2(1, 0),
    vec2(0, 0)
  ]

  setBackground(gl)
  render(gl, pointsTriangle)

  # Part 2
  gl = setupCanvas('part_2')

  setBackground(gl)
  program = loadShaders(gl, 'vertex-shader')
  createBuffer(gl, pointsTriangle)
  writeData(gl, 'vPosition', program, 2)

  renderPoints(gl, pointsTriangle)

  # Part 3
  gl = setupCanvas('part_3')
  colors = [
    vec3(1.0, 0.0, 0.0),
    vec3(0.0, 1.0, 0.0),
    vec3(0.0, 0.0, 1.0)
  ]

  setBackground(gl)
  program = loadShaders(gl, 'vertex-shader-color')
  createBuffer(gl, pointsTriangle)
  writeData(gl, 'vPosition', program, 2)
  createBuffer(gl, colors)
  writeData(gl, 'vColor', program, 3)

  renderTriangles(gl, pointsTriangle)

  # Part 4
  gl = setupCanvas('part_4')

  pointsSquare = [
    [0, 0.5],
    [0.5, 0],
    [-0.5, 0],
    [0, -0.5]
  ]

  setBackground(gl)
  program = loadShaders(gl, 'vertex-shader-square')
  createBuffer(gl, pointsSquare)
  writeData(gl, 'vPosition', program, 2)
  thetaLoc = gl.getUniformLocation(program, "theta")

  renderAnimation(gl, pointsSquare, 0.0, thetaLoc)

  # Part 5
  gl = setupCanvas('part_5');

  pointsCircle = [
    [0.0, 0.0]
  ]

  radius = 0.5
  step = 0.1

  for i in [0..2*Math.PI + step] by step
    pointsCircle.push [Math.cos(i) * radius, Math.sin(i) * radius]

  setBackground(gl)
  program = loadShaders(gl, 'vertex-shader-circle')
  createBuffer(gl, pointsCircle)
  writeData(gl, 'vPosition', program, 2)
  thetaLoc = gl.getUniformLocation(program, "theta")

  renderCirlce(gl, pointsCircle, 0.0, thetaLoc)


setupCanvas = (id) ->
  canvas = document.getElementById(id)
  WebGLUtils.setupWebGL(canvas)


setBackground = (gl) ->
  gl.clearColor(0.3921, 0.5843, 0.9294, 1.0)

createBuffer = (gl, data) ->
  buffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
  gl.bufferData(gl.ARRAY_BUFFER, flatten(data), gl.STATIC_DRAW)

writeData = (gl, attribute, program, pointerSize) ->
  vAttribute = gl.getAttribLocation(program, attribute)
  gl.vertexAttribPointer(vAttribute, pointerSize, gl.FLOAT, false, 0, 0)
  gl.enableVertexAttribArray(vAttribute)

loadShaders = (gl, shader) ->
  program = initShaders(gl, shader, "fragment-shader")
  gl.useProgram(program)
  program

render = (gl) ->
  gl.clear(gl.COLOR_BUFFER_BIT)

renderPoints = (gl, points) ->
  gl.clear(gl.COLOR_BUFFER_BIT)
  gl.drawArrays(gl.POINTS, 0, points.length)

renderTriangles = (gl, points) ->
  gl.clear(gl.COLOR_BUFFER_BIT)
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, points.length)

renderAnimation = (gl, points, theta, thetaLoc) ->
  gl.clear(gl.COLOR_BUFFER_BIT)
  theta -= 0.1
  gl.uniform1f(thetaLoc, theta)
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, points.length)

  requestAnimFrame ->
    renderAnimation(gl, points, theta, thetaLoc)

renderCirlce = (gl, points, theta, thetaLoc) ->
  gl.clear(gl.COLOR_BUFFER_BIT)
  theta -= 0.1
  gl.uniform1f(thetaLoc, theta)
  gl.drawArrays(gl.TRIANGLE_FAN, 0, points.length)

  requestAnimFrame ->
    renderCirlce(gl, points, theta, thetaLoc)

