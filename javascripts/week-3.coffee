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
  constructor: (selector)->
    # Part 1
    @container = document.getElementById(selector)
    @gl = @setupCanvas(selector)
    @canvas = @gl.canvas
    @gl.enable(@gl.DEPTH_TEST)
    @points = []
    @colors = []

    @setBackground()
    @render()

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

  loadShaders: (shader) ->
    program = initShaders(@gl, shader, "fragment-shader")
    @gl.useProgram(program)
    program

  render: () ->

    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
    # @gl.clear(@gl.COLOR_BUFFER_BIT)
    @gl.drawArrays(@gl.LINES, 0, @points.length)

class Part1Canvas extends Canvas
  vertices: [
    vec4(-0.5, -0.5,  0.5, 1.0),
    vec4(-0.5,  0.5,  0.5, 1.0),
    vec4(0.5,  0.5,  0.5, 1.0),
    vec4(0.5, -0.5,  0.5, 1.0),
    vec4(-0.5, -0.5, -0.5, 1.0),
    vec4(-0.5,  0.5, -0.5, 1.0),
    vec4(0.5,  0.5, -0.5, 1.0),
    vec4(0.5, -0.5, -0.5, 1.0)
  ]
  constructor: (selector = 'part_1')->
    super(selector)
    @program = @loadShaders('vertex-shader-color')

    @quad(1, 0, 3, 2)
    @quad(2, 3, 7, 6)
    @quad(3, 0, 4, 7)
    @quad(6, 5, 1, 2)
    @quad(4, 5, 6, 7)
    @quad(5, 4, 0, 1)

    @vBuffer = @createBuffer(flatten(@points))
    @writeData('vPosition', 4)
    @cBuffer = @createBuffer(flatten(@colors))
    @writeData('vColor', 4)

    @render()


  quad: (a, b, c, d) ->
    indices = [ a, b, c, a, c, d ]
    for index in indices
      @points.push(@vertices[index])
      @colors.push(@vertexColors[index])

window.onload = ->
  new Part1Canvas()




