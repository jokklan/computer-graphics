---
---
class Canvas
  vertexColors:  [
    [ 0.0, 0.0, 0.0, 1.0 ],  # black
    [ 1.0, 0.0, 0.0, 1.0 ],  # red
    [ 1.0, 1.0, 0.0, 1.0 ],  # yellow
    [ 0.0, 1.0, 0.0, 1.0 ],  # green
    [ 0.0, 0.0, 1.0, 1.0 ],  # blue
    [ 1.0, 0.0, 1.0, 1.0 ],  # magenta
    [ 1.0, 1.0, 1.0, 1.0 ],  # white
    [ 0.0, 1.0, 1.0, 1.0 ]   # cyan
  ]

  vertices: [
    vec4(-0.5, -0.5, 0.5,  1.0),
    vec4(-0.5, 0.5,  0.5,  1.0),
    vec4(0.5,  0.5,  0.5,  1.0),
    vec4(0.5,  -0.5, 0.5,  1.0),
    vec4(-0.5, -0.5, -0.5, 1.0),
    vec4(-0.5, 0.5,  -0.5, 1.0),
    vec4(0.5,  0.5,  -0.5, 1.0),
    vec4(0.5,  -0.5, -0.5, 1.0)
  ]

  constructor: (selector)->
    # Part 1
    @container = document.getElementById(selector)
    @gl = @setupCanvas(selector)
    @canvas = @gl.canvas
    @points = []
    @colors = []

    @setBackground()
    @gl.enable(@gl.DEPTH_TEST)
    @setup()

  setup: ->

  drawCube: ->
    @quad(1, 0, 3, 2)
    @quad(2, 3, 7, 6)
    @quad(3, 0, 4, 7)
    @quad(6, 5, 1, 2)
    @quad(4, 5, 6, 7)
    @quad(5, 4, 0, 1)

  quad: (a, b, c, d) ->
    indices = [ a, b, c, a, c, d ]
    for index in indices
      @points.push(@vertices[index])
      @colors.push(@vertexColors[index])

  setupCanvas: ->
    canvas = @container.getElementsByTagName('canvas')[0]
    WebGLUtils.setupWebGL(canvas)

  setBackground: ->
    @gl.clearColor(0.3921, 0.5843, 0.9294, 1.0)

  createBuffer: (data) ->
    buffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ARRAY_BUFFER, buffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, data, @gl.STATIC_DRAW)
    buffer

  writeData: (attribute, pointerSize) ->
    vAttribute = @gl.getAttribLocation(@program, attribute)
    @gl.vertexAttribPointer(vAttribute, pointerSize, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(vAttribute)

  loadShaders: ->
    program = initShaders(@gl, "#{window.baseurl}/shaders/vshader-#{@shader_version}.glsl", "#{window.baseurl}/shaders/fshader.glsl")
    @gl.useProgram(program)
    program

  render: (numOfVertices, offset = 0) ->

    @gl.drawArrays(@gl.LINE_LOOP, offset, numOfVertices)

class Part1Canvas extends Canvas
  shader_version: '3-1'
  constructor: (selector = 'part_1')->
    super(selector)

  setup: ->
    @drawCube()
    @program = @loadShaders()

    @modelViewMatrixLoc = @gl.getUniformLocation(@program, "modelViewMatrix")

    @vBuffer = @createBuffer(flatten(@points))
    @writeData('vPosition', 4)
    @cBuffer = @createBuffer(flatten(@colors))
    @writeData('vColor', 4)

    @setModelViewMatrix(0.1, 0, 0)

    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
    @render(36)

  setModelViewMatrix:(radius, theta, phi) ->
    theta  = theta * Math.PI/180.0
    phi    = phi * Math.PI/180.0

    at = vec3(0.0, 0.0, 0.0)
    up = vec3(0.0, 1.0, 0.0)
    eye = vec3(radius*Math.sin(phi), radius*Math.sin(theta), radius*Math.cos(phi))

    modelViewMatrix = lookAt(eye, at , up)

    @gl.uniformMatrix4fv(@modelViewMatrixLoc, false, flatten(modelViewMatrix))


class Part2Canvas extends Part1Canvas
  shader_version: '3-2'
  constructor: (selector = 'part_2')->
    super(selector)

  setup: ->
    @drawCube()

    @program = @loadShaders()

    @modelViewMatrixLoc = @gl.getUniformLocation(@program, "modelViewMatrix")
    @projectionMatrixLoc = @gl.getUniformLocation(@program, "projectionMatrix")

    @vBuffer = @createBuffer(flatten(@points))
    @writeData('vPosition', 4)
    @cBuffer = @createBuffer(flatten(@colors))
    @writeData('vColor', 4)

    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

    @setModelViewMatrix(0.1, 0, 0)
    @setPerspective(10, 3, 2)
    @render(36)

    @setModelViewMatrix(0.1, 0, 45)
    @setPerspective(10, 3, 0)
    @render(36)

    @setModelViewMatrix(0.1, 45, 45)
    @setPerspective(10, 3, -2)
    @render(36)

  setPerspective:(depth, size = 1, xOffset = 0, yOffset = 0) ->
    near = -depth
    far = depth
    left = -size + xOffset
    right = size + xOffset
    ytop = size + yOffset
    bottom = -size + yOffset

    projectionMatrix = ortho(left, right, bottom, ytop, near, far)

    @gl.uniformMatrix4fv(@projectionMatrixLoc, false, flatten(projectionMatrix))

class Part4Canvas extends Part2Canvas
  constructor: (selector = 'part_4')->
    super(selector)

# Part 3
## Part 1



## Part 2



window.onload = ->
  new Part1Canvas()
  new Part2Canvas()
  # new Part4Canvas()
