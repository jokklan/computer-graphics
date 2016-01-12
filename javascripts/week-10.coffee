---
---
class Canvas
  constructor: (selector)->
    # Part 1
    @container = document.getElementById(selector)
    @gl = @setupCanvas(selector)
    @canvas = @gl.canvas
    @reset()

    @setBackground()

    @gl.viewport(0, 0, @canvas.width, @canvas.height)
    @gl.enable(@gl.DEPTH_TEST)
    @gl.enable(@gl.CULL_FACE)
    @gl.cullFace(@gl.BACK)

    @setup()
    @tick()

  tick: ->
    @draw()
    requestAnimationFrame =>
      @tick()

  setup: ->

  draw: ->

  reset: ->
    @spherePoints = []
    @sphereColors = []
    @sphereNormals = []

    @wallPoints = []
    @wallColors = []
    @wallTexCoordsArray = []

  setupCanvas: ->
    canvas = @container.getElementsByTagName('canvas')[0]
    WebGLUtils.setupWebGL(canvas)

  setBackground: ->
    @gl.clearColor(0.3921, 0.5843, 0.9294, 1.0)

  loadShaders: ->
    program = initShaders(@gl, "#{window.baseurl}/shaders/vshader-#{@program_version}.glsl", "#{window.baseurl}/shaders/fshader-#{@program_version}.glsl")
    @gl.useProgram(program)
    program

  configureTextureImage: (image, textureIndex = 0)->
    @gl.activeTexture(@gl["TEXTURE#{textureIndex}"]);
    texture = @gl.createTexture()
    @gl.bindTexture(@gl.TEXTURE_2D, texture)
    @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGB, @gl.RGB, @gl.UNSIGNED_BYTE, image)
    # @gl.generateMipmap(@gl.TEXTURE_2D)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
    return texture;

  getModelViewMatrix: ->
    at = vec3(0.0, 0.0, 0.0)
    up = vec3(0.0, 1.0, 0.0)
    eye = vec3(0.0, 0.0, 3.0)

    modelViewMatrix = lookAt(eye, at, up);

  getProjectionMatrix: ->
    fovy = 90.0
    aspect = 1.0
    near = 0.1
    far = 100.0
    projectionMatrix = perspective(fovy, aspect, near, far)

  generateTextureImage: (texSize)->
    numRows = 8
    numCols = 8
    texels = new Uint8Array(4 * texSize * texSize)

    for i in [0...texSize] by 1
      for j in [0...texSize] by 1
        patchx = Math.floor(i / (texSize / numRows))
        patchy = Math.floor(j / (texSize / numCols))

        c = if patchx % 2 != patchy % 2 then 255 else 0

        texels[4 * i * texSize + 4 * j]     = c
        texels[4 * i * texSize + 4 * j + 1] = c
        texels[4 * i * texSize + 4 * j + 2] = c
        texels[4 * i * texSize + 4 * j + 3] = 255
    return texels


  quad: (a, b, c, d) ->
    vertexIndices = [a, b, c, d]
    indices = [0, 1, 2, 0, 2, 3]

    for index in indices
      vertexIndex = vertexIndices[index]
      @wallPoints.push(@wallVertices[vertexIndex])
      # @wallTexCoordsArray.push(@texCoords[index])
      # @wallColors.push(@vertexColors[1])

  configureTexture: (image)->
    texture = @gl.createTexture()
    @gl.bindTexture(@gl.TEXTURE_2D, texture)
    @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGB, @gl.RGB, @gl.UNSIGNED_BYTE, image)
    @gl.generateMipmap(@gl.TEXTURE_2D)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
    @gl.uniform1i(@gl.getUniformLocation(@program, "texMap"), 0)

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
    @spherePoints.push(a)
    @spherePoints.push(b)
    @spherePoints.push(c)

    @sphereNormals.push(a)
    @sphereNormals.push(b)
    @sphereNormals.push(c)

  setLightningProduct: (type, light, material)->
    product = mult(light, material)
    @gl.uniform4fv(@gl.getUniformLocation(@program, type), product)

  # Create a buffer object, assign it to attribute variables, and enable the assignment
  createEmptyArrayBuffer: (v_attribute, num, type) ->
    buffer = @gl.createBuffer() # Create a buffer object

    @gl.bindBuffer(@gl.ARRAY_BUFFER, buffer)
    @gl.vertexAttribPointer(v_attribute, num, type, false, 0, 0);
    @gl.enableVertexAttribArray(v_attribute); # Enable the assignment

    buffer

class Part1Canvas extends Canvas
  program_version: '10-1'
  subdivisionLevel: 4
  sphereVertices: [
    vec4(0.0, 0.0, 1.0, 1),
    vec4(0.0, 0.942809, -0.333333, 1),
    vec4(-0.816497, -0.471405, -0.333333, 1),
    vec4(0.816497, -0.471405, -0.333333, 1)
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
    vec2(-1.5, 0.0),
    vec2(2.5, 0.0),
    vec2(2.5, 10.0),
    vec2(-1.5, 10.0)
  ]
  cubeMapPaths:
    POSITIVE_X: "#{window.baseurl}/resources/textures/cm_left.png"
    NEGATIVE_X: "#{window.baseurl}/resources/textures/cm_right.png"
    POSITIVE_Y: "#{window.baseurl}/resources/textures/cm_top.png"
    NEGATIVE_Y: "#{window.baseurl}/resources/textures/cm_bottom.png"
    POSITIVE_Z: "#{window.baseurl}/resources/textures/cm_back.png"
    NEGATIVE_Z: "#{window.baseurl}/resources/textures/cm_front.png"

  phi: 180.0
  theta: 0.0
  speed: 1.0


  constructor: (selector = 'part_1')->
    super(selector)

  setup: ->
    @program = @generateProgram()
    @sphereObject = @loadSphere()

    @imageLoadCount = 0
    @cubeMapImages = {}

    for face, texturePath of @cubeMapPaths
      image = new Image()
      image.crossOrigin = 'anonymous'
      image.src = texturePath
      image.onload = =>
        @imageLoadCount += 1

        if @imageLoadCount >= 6
          @program.cubeMap = @configureTextureFromCube()

      @cubeMapImages[face] = image

  generateProgram: ->
    program = initShaders(@gl, "#{window.baseurl}/shaders/vshader-10-1.glsl", "#{window.baseurl}/shaders/fshader-10-1.glsl")
    @gl.useProgram(program)
    program.vPositionLoc = @gl.getAttribLocation(program, "vPosition");
    program.vNormalLoc = @gl.getAttribLocation(program, "vNormal");
    program.cubeSampler = @gl.getUniformLocation(program, "cubeSampler");
    # # program.normalSampler = @gl.getUniformLocation(program, "normalSampler");
    # # program.isMirrorLoc = gl.getUniformLocation(program, "isMirror");
    program.modelViewMatrixLoc = @gl.getUniformLocation(program, "modelViewMatrix");
    program.projectionMatrixLoc = @gl.getUniformLocation(program, "projectionMatrix");
    # program.MtexLoc = gl.getUniformLocation(program, "Mtex");
    # program.eyeLoc = gl.getUniformLocation(program, "eye");
    return program

  loadSphere: ->
    sphereObject = new Object()
    sphereObject.projectionMatrix = @getProjectionMatrix()
    sphereObject.modelViewMatrix = @getModelViewMatrix()
    # sphereObject.Mtex = mat4();

    @tetrahedron(@sphereVertices[0], @sphereVertices[1], @sphereVertices[2], @sphereVertices[3], @subdivisionLevel)

    vertexBuffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ARRAY_BUFFER, vertexBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@spherePoints), @gl.STATIC_DRAW)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)
    sphereObject.vertexBuffer = vertexBuffer

    normalBuffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ARRAY_BUFFER, normalBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@sphereNormals), @gl.STATIC_DRAW)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)
    sphereObject.normalBuffer = normalBuffer


    sphereObject.n_vertices = @spherePoints.length

    return sphereObject;

  configureTextureFromCube: ->
    cubeMap = @gl.createTexture()
    @gl.bindTexture(@gl.TEXTURE_CUBE_MAP, cubeMap)
    @gl.activeTexture(@gl.TEXTURE0)
    @gl.pixelStorei(@gl.UNPACK_FLIP_Y_WEBGL, true)

    for face, image of @cubeMapImages
      @gl.texImage2D(@gl["TEXTURE_CUBE_MAP_#{face}"], 0, @gl.RGB, @gl.RGB, @gl.UNSIGNED_BYTE, image)

    @gl.texParameteri(@gl.TEXTURE_CUBE_MAP, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR)
    @gl.bindTexture(@gl.TEXTURE_CUBE_MAP, null)
    return cubeMap

  drawSphere: ->
    @gl.uniformMatrix4fv(@program.modelViewMatrixLoc, false, flatten(@sphereObject.modelViewMatrix))
    @gl.uniformMatrix4fv(@program.projectionMatrixLoc, false, flatten(@sphereObject.projectionMatrix))

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @sphereObject.vertexBuffer)
    @gl.vertexAttribPointer(@program.vPositionLoc, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@program.vPositionLoc)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @sphereObject.normalBuffer)
    @gl.vertexAttribPointer(@program.vNormalLoc, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@program.vNormalLoc)

    # @gl.uniformMatrix4fv(@program.MtexLoc, false, flatten(@sphereObject.Mtex))
    # @gl.uniform1i(@program.isMirrorLoc, 1)
    # @gl.uniform4fv(@program.eyeLoc,vec4(eye))

    @gl.drawArrays(@gl.TRIANGLES, 0, @sphereObject.n_vertices)


  draw: ->
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

    if @program.cubeMap
      @gl.activeTexture(@gl.TEXTURE0)
      @gl.bindTexture(@gl.TEXTURE_CUBE_MAP, @program.cubeMap)
      @gl.uniform1i(@program.cubeSampler, 0)

    @drawSphere()

class Part2Canvas extends Part1Canvas
  wallVertices: [
    vec4(-1.0, -1.0, 0.999, 1.0),
    vec4(-1.0, 1.0,  0.999, 1.0),
    vec4(1.0,  1.0,  0.999, 1.0),
    vec4(1.0,  -1.0, 0.999, 1.0)
  ]

  constructor: (selector = 'part_2')->
    super(selector)

  setup: ->
    @program = @generateProgram()

    @floorObject = @setupFloor()
    @sphereObject = @loadSphere()

    @imageLoadCount = 0
    @cubeMapImages = {}

    for face, texturePath of @cubeMapPaths
      image = new Image()
      image.crossOrigin = 'anonymous'
      image.src = texturePath
      image.onload = =>
        @imageLoadCount += 1

        if @imageLoadCount >= 6
          @program.cubeMap = @configureTextureFromCube()

      @cubeMapImages[face] = image

  setupFloor: ->
    @quad(0, 1, 2, 3)
    floorObject = new Object()
    floorObject.vertexBuffer = @createEmptyArrayBuffer(@program.vPositionLoc, 4, @gl.FLOAT)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, floorObject.vertexBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@wallPoints), @gl.STATIC_DRAW)

    projectionMatrix = @getProjectionMatrix()
    floorObject.projectionMatrix = projectionMatrix
    floorObject.modelViewMatrix = mat4()
    floorObject.Mtex = inverse(projectionMatrix)

    return floorObject

  loadSphere: ->
    sphereObject = new Object()
    sphereObject.projectionMatrix = @getProjectionMatrix()
    sphereObject.modelViewMatrix = @getModelViewMatrix()
    sphereObject.Mtex = mat4()

    @tetrahedron(@sphereVertices[0], @sphereVertices[1], @sphereVertices[2], @sphereVertices[3], @subdivisionLevel)

    vertexBuffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ARRAY_BUFFER, vertexBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@spherePoints), @gl.STATIC_DRAW)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)
    sphereObject.vertexBuffer = vertexBuffer

    normalBuffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ARRAY_BUFFER, normalBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@sphereNormals), @gl.STATIC_DRAW)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)
    sphereObject.normalBuffer = normalBuffer

    sphereObject.n_vertices = @spherePoints.length

    return sphereObject;

  generateProgram: ->
    program = initShaders(@gl, "#{window.baseurl}/shaders/vshader-10-2.glsl", "#{window.baseurl}/shaders/fshader-10-2.glsl")
    @gl.useProgram(program)
    program.vPositionLoc = @gl.getAttribLocation(program, "vPosition");
    program.vNormalLoc = @gl.getAttribLocation(program, "vNormal");
    program.cubeSampler = @gl.getUniformLocation(program, "cubeSampler");
    # # program.normalSampler = @gl.getUniformLocation(program, "normalSampler");
    # # program.isMirrorLoc = gl.getUniformLocation(program, "isMirror");
    program.modelViewMatrixLoc = @gl.getUniformLocation(program, "modelViewMatrix");
    program.projectionMatrixLoc = @gl.getUniformLocation(program, "projectionMatrix");
    program.MtexLoc = @gl.getUniformLocation(program, "Mtex");
    # program.eyeLoc = gl.getUniformLocation(program, "eye");
    return program

  drawSphere: ->
    @gl.uniformMatrix4fv(@program.modelViewMatrixLoc, false, flatten(@sphereObject.modelViewMatrix))
    @gl.uniformMatrix4fv(@program.projectionMatrixLoc, false, flatten(@sphereObject.projectionMatrix))
    @gl.uniformMatrix4fv(@program.MTexLoc, false, flatten(mat4()))

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @sphereObject.vertexBuffer)
    @gl.vertexAttribPointer(@program.vPositionLoc, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@program.vPositionLoc)

    # @gl.bindBuffer(@gl.ARRAY_BUFFER, @sphereObject.normalBuffer)
    # @gl.vertexAttribPointer(@program.vNormalLoc, 4, @gl.FLOAT, false, 0, 0)
    # @gl.enableVertexAttribArray(@program.vNormalLoc)

    @gl.drawArrays(@gl.TRIANGLES, 0, @sphereObject.n_vertices)

  drawFloor: ->
    @gl.uniformMatrix4fv(@program.modelViewMatrixLoc, false, flatten(@floorObject.modelViewMatrix))
    @gl.uniformMatrix4fv(@program.projectionMatrixLoc, false, flatten(@floorObject.projectionMatrix))
    @gl.uniformMatrix4fv(@program.MTexLoc, false, flatten(@floorObject.Mtex))

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.vertexBuffer)
    @gl.vertexAttribPointer(@program.vPosition, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@program.vPosition)

    # @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.colorBuffer)
    # @gl.vertexAttribPointer(@program.vColor, 4, @gl.FLOAT, false, 0, 0)
    # @gl.enableVertexAttribArray(@program.vColor)

    # @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.textureBuffer)
    # @gl.vertexAttribPointer(@program.vTexCoord, 2, @gl.FLOAT, false, 0, 0)
    # @gl.enableVertexAttribArray(@program.vTexCoord)



    # if @floorObject.cubeMap
    #   @gl.activeTexture(@gl.TEXTURE0)
    #   @gl.bindTexture(@gl.TEXTURE_CUBE_MAP, @floorObject.cubeMap)
    #   @gl.uniform1i(@program.cubeSampler, 0)
    #   console.log("HEJH")

    @gl.drawArrays(@gl.TRIANGLES, 0, 6)


  draw: ->
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

    if @program.cubeMap
      @gl.activeTexture(@gl.TEXTURE0)
      @gl.bindTexture(@gl.TEXTURE_CUBE_MAP, @program.cubeMap)
      @gl.uniform1i(@program.cubeSampler, 0)

    @drawSphere()

window.onload = ->
  new Part1Canvas()
  new Part2Canvas()

