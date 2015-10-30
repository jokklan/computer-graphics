---
---
class Canvas
  constructor: (selector)->
    # Part 1
    @container = document.getElementById(selector)
    @gl = @setupCanvas(selector)
    @canvas = @gl.canvas
    @reset()

    # @gl.viewport(0, 0, @canvas.width, @canvas.height)
    @setBackground()

    @program = @loadShaders()

    @gl.enable(@gl.DEPTH_TEST)

    @setup()
    @tick()

  tick: ->
    @draw()
    requestAnimationFrame =>
      @tick()

  setup: ->

  draw: ->

  reset: ->

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
    program = initShaders(@gl, "/shaders/vshader-#{@program_version}.glsl", "/shaders/fshader-#{@program_version}.glsl")
    @gl.useProgram(program)
    program


  setModelViewMatrix:() ->
    at = vec3(0.0, 0.0, 0.0)
    up = vec3(0.0, 1.0, 0.0)
    eye = vec3(0.0, 0.0, 1.0)

    modelViewMatrix = lookAt(eye, at, up);

    @gl.uniformMatrix4fv(@modelViewMatrixLoc, false, flatten(modelViewMatrix) )

  setPerspective:(fovy = 90, aspect = 1.0, near = 0.3, far = 10) ->
    projectionMatrix = perspective(fovy, aspect, near, far)

    @gl.uniformMatrix4fv(@projectionMatrixLoc, false, flatten(projectionMatrix))


class Part1Canvas extends Canvas
  program_version: '7-1'
  vertices: [
    vec4(-2.0, -1.0, -5.0, 1.0),
    vec4(-2.0, -1.0, -1.0, 1.0),
    vec4(2.0,  -1.0, -1.0, 1.0),
    vec4(2.0,  -1.0, -5.0, 1.0)

    vec4(0.25, -0.5, -1.75, 1.0),
    vec4(0.25, -0.5, -1.25, 1.0),
    vec4(0.75, -0.5, -1.25, 1.0),
    vec4(0.75, -0.5, -1.75, 1.0),

    vec4(-1.0, -1.0, -3.0, 1.0),
    vec4(-1.0, -1.0, -2.5, 1.0),
    vec4(-1.0,  0.0, -2.5, 1.0),
    vec4(-1.0,  0.0, -3.0, 1.0)
  ]
  vertexColors: [
    vec4( 0.0, 0.0, 0.0, 1.0 ),  # black
    vec4( 1.0, 1.0, 1.0, 1.0 ),  # white
    vec4( 1.0, 0.0, 0.0, 1.0 ),  # red
    vec4( 1.0, 1.0, 0.0, 1.0 ),  # yellow
    vec4( 0.0, 1.0, 0.0, 1.0 ),  # green
    vec4( 0.0, 0.0, 1.0, 1.0 ),  # blue
    vec4( 1.0, 0.0, 1.0, 1.0 ),  # magenta
    vec4( 0.0, 1.0, 1.0, 1.0 )   # cyan
  ]
  texCoords: [
    vec2(0.0, 0.0),
    vec2(0.0, 1.0),
    vec2(1.0, 1.0),
    vec2(1.0, 0.0)
  ]


  constructor: (selector = 'part_1')->
    super(selector)

  reset: ->
    @points = []
    @colors = []
    @texCoordsArray = [ ]

  setup: ->
    @modelViewMatrixLoc = @gl.getUniformLocation(@program, "modelViewMatrix")
    @projectionMatrixLoc = @gl.getUniformLocation(@program, "projectionMatrix")

    @quad(0, 1, 2, 3)
    @quad(4, 5, 6, 7)
    @quad(8, 9, 10, 11)


    @lightPosition = vec4(2.0, 2.0, -2.0, 0.0 )

    @vBuffer = @createBuffer(flatten(@colors))
    @writeData('vColor', 4)

    @vBuffer = @createBuffer(flatten(@points))
    @writeData('vPosition', 4)

    @vBuffer = @createBuffer(flatten(@texCoordsArray))
    @writeData('vTexCoord', 2)

    @setModelViewMatrix()
    @setPerspective()

    image = new Image()
    image.crossOrigin = 'anonymous'
    image.onload = =>
      @textureImage = @configureTextureImage(image, 0)

    image.src = "/resources/xamp23.png"

    redTexture = new Uint8Array(4)
    redTexture[0] = 255
    redTexture[1] = 0
    redTexture[2] = 0
    redTexture[3] = 255
    @textureArray = @configureTextureArray(1, redTexture, 1)

    blackTexture = new Uint8Array(4)
    blackTexture[0] = 0
    blackTexture[1] = 0
    blackTexture[2] = 0
    blackTexture[3] = 255
    @textureArray2 = @configureTextureArray(2, blackTexture, 2)

  configureTextureImage: (image, textureIndex = 0)->
    @gl.activeTexture(@gl["TEXTURE#{textureIndex}"]);
    texture = @gl.createTexture()
    @gl.bindTexture(@gl.TEXTURE_2D, texture)
    @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGB, @gl.RGB, @gl.UNSIGNED_BYTE, image)
    @gl.generateMipmap(@gl.TEXTURE_2D)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
    return texture;

  configureTextureArray: (texSize, image, textureIndex = 0)->
    @gl.activeTexture(@gl["TEXTURE#{textureIndex}"]);
    texture = @gl.createTexture()
    @gl.bindTexture(@gl.TEXTURE_2D, texture)
    @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, texSize, texSize, 0, @gl.RGBA, @gl.UNSIGNED_BYTE, image)
    @gl.generateMipmap(@gl.TEXTURE_2D)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.REPEAT)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
    return texture;

  writeTexture: (texture, index)->
    @gl.uniform1i(@gl.getUniformLocation(@program, "texMap"), index)


  quad: (a, b, c, d) ->
    vertexIndices = [a, b, c, d]
    indices = [0, 1, 2, 0, 2, 3]

    for index in indices
      vertexIndex = vertexIndices[index]
      @points.push(@vertices[vertexIndex])
      @texCoordsArray.push(@texCoords[index])
      @colors.push(@vertexColors[1])

  draw: ->
    @gl.clear(@gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT) # Clear color and depth buffers

    # Draw
    @writeTexture(@textureImage, 0)
    @gl.drawArrays(@gl.TRIANGLES, 0, 6)

    @writeTexture(@textureArray, 1)
    @gl.drawArrays(@gl.TRIANGLES, 6, 6)
    @gl.drawArrays(@gl.TRIANGLES, 12, 6)



class Part2Canvas extends Part1Canvas
  program_version: '7-1'
  theta: 0.0
  speed: 0.1

  constructor: (selector = 'part_2')->
    super(selector)

  draw: ->
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)
    @theta += @speed

    if @theta > 2 * Math.PI
      @theta -= 2 * Math.PI

    at = vec3(0.0, 0.0, -1.0)
    up = vec3(0.0, 1.0, 0.0)
    eye = vec3(0.0, 1.0, 0.0)


    modelViewMatrix = lookAt(eye, at, up)

    @gl.uniformMatrix4fv(@modelViewMatrixLoc, false, flatten(modelViewMatrix))

    @writeTexture(@textureImage, 0)
    @gl.drawArrays(@gl.TRIANGLES, 0, 6)

    @writeTexture(@textureArray, 1)
    @gl.drawArrays(@gl.TRIANGLES, 6, 6)
    @gl.drawArrays(@gl.TRIANGLES, 12, 6)

    # Rotate light source
    @lightPosition = vec4(0.0, 2.0, -2.0, 0.0)
    @lightPosition[0] = Math.sin(@theta) * 2.0
    @lightPosition[2] = Math.cos(@theta) * 2.0 - 2.0

    m = mat4() # Shadow projection matrix initially an identity matrix
    m[3][3] = 0.0
    m[3][1] = -1.0/@lightPosition[1]

    # Model-view matrix for shadow then render
    modelViewMatrix = mult(modelViewMatrix, translate(@lightPosition[0], @lightPosition[1], @lightPosition[2]))
    modelViewMatrix = mult(modelViewMatrix, m)
    modelViewMatrix = mult(modelViewMatrix, translate(-@lightPosition[0], -@lightPosition[1], -@lightPosition[2]))
    # modelViewMatrix = mult(modelViewMatrix, translate(0, -1.0, 0))

    # Send matrix for shadow
    @gl.uniformMatrix4fv(@modelViewMatrixLoc, false, flatten(modelViewMatrix))

    @writeTexture(@textureArray2, 2)
    @gl.drawArrays(@gl.TRIANGLES, 6, 6)
    @gl.drawArrays(@gl.TRIANGLES, 12, 6)

window.onload = ->
  new Part1Canvas()
  new Part2Canvas()
