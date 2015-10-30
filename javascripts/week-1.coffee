---
---
class Canvas
  constructor: (selector)->
    @container = document.getElementById(selector)
    @gl = @setupCanvas(selector)
    @canvas = @gl.canvas

    @setBackground()
    @setup()
    @render()

  setup: ->

  setupCanvas: ->
    canvas = @container.getElementsByTagName('canvas')[0]
    WebGLUtils.setupWebGL(canvas)

  setBackground: ->
    @gl.clearColor(0.3921, 0.5843, 0.9294, 1.0)

  render:->
    @clear()

  clear: ->
    @gl.clear(@gl.COLOR_BUFFER_BIT)

class Part1Canvas extends Canvas
  constructor: (selector = 'part_1')->
    super(selector)


class Part2Canvas extends Canvas
  shader_version: '1-2'
  points: [
    vec2(1, 1),
    vec2(1, 0),
    vec2(0, 0)
  ]

  constructor: (selector = 'part_2')->
    super(selector)

  setup: ->
    @program = @loadShaders()
    @vBuffer = @createBuffer(flatten(@points))
    @writeData('vPosition', 2)

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

  render: ->
    super()
    @draw()

  draw: ->
    @gl.drawArrays(@gl.POINTS, 0, @points.length)


class Part3Canvas extends Part2Canvas
  shader_version: '1-3'
  colors: [
    vec3(1.0, 0.0, 0.0),
    vec3(0.0, 1.0, 0.0),
    vec3(0.0, 0.0, 1.0)
  ]

  constructor: (selector = 'part_3')->
    super(selector)

  setup: ->
    super()

    @vBuffer = @createBuffer(flatten(@colors))
    @writeData('vColor', 3)

  draw: ->
    @gl.drawArrays(@gl.TRIANGLE_STRIP, 0, @points.length)

class Part4Canvas extends Part3Canvas
  shader_version: '1-4'
  points: [
    [0, 0.5],
    [0.5, 0],
    [-0.5, 0],
    [0, -0.5]
  ]
  speed: 0.1
  theta: 0.0

  constructor: (selector = 'part_4')->
    super(selector)

  setup: ->
    super()
    @thetaLoc = @gl.getUniformLocation(@program, "theta")

  render: ->
    super()

    requestAnimFrame =>
      @render()

  draw: ->
    @theta -= @speed
    @gl.uniform1f(@thetaLoc, @theta)
    @gl.drawArrays(@gl.TRIANGLE_STRIP, 0, @points.length)

class Part5Canvas extends Part4Canvas
  shader_version: '1-5'
  points: [
    [0.0, 0.0]
  ]

  constructor: (selector = 'part_5')->
    super(selector)

  setup: ->
    @drawCircle(0.5)
    super()

  drawCircle: (radius, step = 0.1)->
    for i in [0..2*Math.PI + step] by step
      @points.push [Math.cos(i) * radius, Math.sin(i) * radius]

  draw: ->
    @theta -= @speed
    @gl.uniform1f(@thetaLoc, @theta)
    @gl.drawArrays(@gl.TRIANGLE_FAN, 0, @points.length)

window.onload = ->
  new Part1Canvas()
  new Part2Canvas()
  new Part3Canvas()
  new Part4Canvas()
  new Part5Canvas()



