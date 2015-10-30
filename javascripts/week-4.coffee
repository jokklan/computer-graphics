---
---
class Canvas
  vertices: [
    vec4(0.0, 0.0, -1.0, 1),
    vec4(0.0, 0.942809, 0.333333, 1),
    vec4(-0.816497, -0.471405, 0.333333, 1),
    vec4(0.816497, -0.471405, 0.333333, 1)
  ]

  constructor: (selector)->
    # Part 1
    @container = document.getElementById(selector)
    @gl = @setupCanvas(selector)
    @canvas = @gl.canvas
    @reset()

    @setBackground()

    @program = @loadShaders()

    @setup()
    @draw()
    @render()

  setup: ->

  draw: ->

  reset: ->
    @points = []

  drawTetrahedron: ->
    @tetrahedron(@vertices[0], @vertices[1], @vertices[2], @vertices[3], @subdivisionLevel)

  tetrahedron: (a, b, c, d, n) ->
    @divideTriangle(a, b, c, n)
    @divideTriangle(d, c, b, n)
    @divideTriangle(a, d, b, n)
    @divideTriangle(a, c, d, n)

  divideTriangle: (a, b, c, count) ->
    if count > 0
      ab = normalize(mix(a, b, 0.5), true)
      ac = normalize(mix(a, c, 0.5), true)
      bc = normalize(mix(b, c, 0.5), true)

      @divideTriangle(a, ab, ac, count - 1)
      @divideTriangle(ab, b, bc, count - 1)
      @divideTriangle(bc, c, ac, count - 1)
      @divideTriangle(ab, bc, ac, count - 1)
    else
      @triangle(a, b, c)

  triangle: (a, b, c)->
    @points.push(a)
    @points.push(b)
    @points.push(c)

  setupSubdivisionButton: (selector, delta) ->
    button = @container.getElementsByClassName(selector)[0]
    button.addEventListener 'click', =>
      @subdivisionLevel += delta if @subdivisionLevel > 0 || delta > 0
      @writeSubdivisionLevel()
      @reset()
      @draw()

  writeSubdivisionLevel: ->
    @container.getElementsByClassName('subdivision_value')[0].innerHTML = @subdivisionLevel

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
    program = initShaders(@gl, "#{window.baseurl}/shaders/vshader-#{@program_version}.glsl", "#{window.baseurl}/shaders/fshader.glsl")
    @gl.useProgram(program)
    program

  setModelViewMatrix:(radius = 6.0, theta = 0.0, phi = 0.0) ->
    theta  = theta * Math.PI/180.0
    phi    = phi * Math.PI/180.0

    at = vec3(0.0, 0.0, 0.0)
    up = vec3(0.0, 1.0, 0.0)
    eye = vec3(radius*Math.sin(phi), radius*Math.sin(theta), radius*Math.cos(phi))

    modelViewMatrix = lookAt(eye, at , up)

    @gl.uniformMatrix4fv(@modelViewMatrixLoc, false, flatten(modelViewMatrix))

  setPerspective:(depth = 10, size = 2.0, xOffset = 0, yOffset = 0) ->
    near = -depth
    far = depth
    left = -size + xOffset
    right = size + xOffset
    ytop = size + yOffset
    bottom = -size + yOffset

    projectionMatrix = ortho(left, right, bottom, ytop, near, far)

    @gl.uniformMatrix4fv(@projectionMatrixLoc, false, flatten(projectionMatrix))

  render: () ->
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

    for i in [0..@points.length - 1] by 3
      @gl.drawArrays(@gl.TRIANGLES, i, 3)

class Part1Canvas extends Canvas
  program_version: '4-1'

  constructor: (selector = 'part_1')->
    super(selector)

  setup: ->
    @subdivisionLevel = 4
    @writeSubdivisionLevel()

    @setupSubdivisionButton('increase_button', 1)
    @setupSubdivisionButton('decrease_button', -1)

    @modelViewMatrixLoc = @gl.getUniformLocation(@program, "modelViewMatrix")
    @projectionMatrixLoc = @gl.getUniformLocation(@program, "projectionMatrix")

    @setModelViewMatrix(1, 0, 0)
    @setPerspective(10)

  draw: ->
    @drawTetrahedron()
    @vBuffer = @createBuffer(flatten(@points))
    @writeData('vPosition', 4)
    @render()


class Part2Canvas extends Part1Canvas
  program_version: '4-2'

  constructor: (selector = 'part_2')->
    super(selector)

  setup: ->
    @gl.enable(@gl.DEPTH_TEST)
    @gl.enable(@gl.CULL_FACE)
    @gl.cullFace(@gl.BACK)

    super()

class Part3Canvas extends Part2Canvas
  program_version: '4-3'
  phi: 0.0
  speed: 1.0

  constructor: (selector = 'part_3')->
    super(selector)

  setup: ->
    super()

    lightPosition = vec4(-1.0, -1.0, -1.5, 0.0 )
    @lightAmbient = vec4(1.0, 1.0, 1.0, 1.0 )
    @lightDiffuse = vec4( 1.0, 1.0, 1.0, 1.0 )
    @lightSpecular = vec4( 1.0, 1.0, 1.0, 1.0 )

    @materialAmbient = vec4( 0.0, 0.5, 0.5, 1.0 )
    @materialDiffuse = vec4( 0.5, 0.5, 0.5, 1.0 )
    @materialSpecular = vec4( 0.0, 0.0, 0.0, 1.0 )
    @materialShininess = 100.0

    @setLightningProduct('ambientProduct', @lightAmbient, @materialAmbient)
    @setLightningProduct('diffuseProduct', @lightDiffuse, @materialDiffuse)
    @setLightningProduct('specularProduct', @lightSpecular, @materialSpecular)
    @gl.uniform4fv(@gl.getUniformLocation(@program, "lightPosition"), flatten(lightPosition))
    @gl.uniform1f(@gl.getUniformLocation(@program, "shininess"), @materialShininess)


  setLightningProduct: (type, light, material)->
    product = mult(light, material)
    @gl.uniform4fv(@gl.getUniformLocation(@program, type), product)

  reset: ->
    super()
    @normals = []

  triangle: (a, b, c)->
    super(a, b, c)
    @normals.push(a)
    @normals.push(b)
    @normals.push(c)

  draw: ->
    @drawTetrahedron()
    @vBuffer = @createBuffer(flatten(@points))
    @writeData('vPosition', 4)

    @nBuffer = @createBuffer(flatten(@normals))
    @writeData('vNormal', 4)

  render: ->
    @setModelViewMatrix(1, 0, @phi)
    @phi += @speed
    super()

    requestAnimFrame =>
      @render()

class Part4Canvas extends Part3Canvas
  constructor: (selector = 'part_4', canvas_selector = 'canvas-dynamic-light', program_version = '4-3')->
    @canvas_selector = canvas_selector
    @program_version = program_version
    super(selector)

  setupCanvas: ->
    canvas = @container.getElementsByClassName(@canvas_selector)[0]
    WebGLUtils.setupWebGL(canvas)

  setup: ->
    super()
    @setSlide('materialAmbient')
    @setSlide('materialDiffuse')
    @setSlide('materialSpecular')

    @setSlide('lightAmbient')
    @setSlide('lightDiffuse')
    @setSlide('lightSpecular')

    slider = @container.getElementsByClassName("materialShininess_slider")[0]
    slider.addEventListener 'change', (event)=>
      value = event.target.value
      @materialShininess = value

      @updateLightning()

  setSlide: (type, delta) ->
    slider = @container.getElementsByClassName("#{type}_slider")[0]
    slider.addEventListener 'change', (event)=>
      value = event.target.value
      @[type] = vec4( value, value, value, 1.0 )

      @updateLightning()

  updateLightning: ->
    @setLightningProduct('ambientProduct', @lightAmbient, @materialAmbient)
    @setLightningProduct('diffuseProduct', @lightDiffuse, @materialDiffuse)
    @setLightningProduct('specularProduct', @lightSpecular, @materialSpecular)
    @gl.uniform1f(@gl.getUniformLocation(@program, "shininess"), @materialShininess)

class Part5Canvas extends Part4Canvas
  constructor: (selector = 'part_5', canvas_selector = 'canvas-dynamic-light', program_version = '4-5')->
    super(selector, canvas_selector, program_version)

  loadShaders: ->
    program = initShaders(@gl, "#{window.baseurl}/shaders/vshader-#{@program_version}.glsl", "#{window.baseurl}/shaders/fshader-#{@program_version}.glsl")
    @gl.useProgram(program)
    program

window.onload = ->
  new Part1Canvas()
  new Part2Canvas()
  new Part3Canvas()
  new Part4Canvas('part_4', 'canvas-dynamic-light')
  new Part4Canvas('part_4', 'canvas-static-light', '4-3-static-light')
  new Part5Canvas('part_5', 'canvas-dynamic-light', '4-5')
  new Part5Canvas('part_5', 'canvas-static-light', '4-5-static-light')
