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
    program = initShaders(@gl, "#{window.baseurl}/shaders/vshader-#{@program_version}.glsl", "#{window.baseurl}/shaders/fshader-#{@program_version}.glsl")
    @gl.useProgram(program)
    program

  getModelViewMatrix: (radius = 2.0, theta = 0.0, phi = 0.0) ->
    theta  = theta * Math.PI/180.0
    phi    = phi * Math.PI/180.0

    at = vec3(0.0, 0.0, 0.0)
    up = vec3(0.0, 1.0, 0.0)
    eye = vec3(radius*Math.sin(phi), radius*Math.sin(theta), radius*Math.cos(phi))

    modelViewMatrix = lookAt(eye, at, up);

  getProjectionMatrix: (fovy = 90, aspect = 1.0, near = 0.3, far = 0) ->
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
      @points.push(@vertices[vertexIndex])
      @texCoordsArray.push(@texCoords[index])
      @colors.push(@vertexColors[1])

  configureTexture: (image)->
    texture = @gl.createTexture()
    @gl.bindTexture(@gl.TEXTURE_2D, texture)
    @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGB, @gl.RGB, @gl.UNSIGNED_BYTE, image)
    @gl.generateMipmap(@gl.TEXTURE_2D)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
    @gl.uniform1i(@gl.getUniformLocation(@program, "texMap"), 0)

  reset: ->
    @points = []
    @colors = []
    @normals = []


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

    @normals.push(a)
    @normals.push(b)
    @normals.push(c)

  setLightningProduct: (type, light, material)->
    product = mult(light, material)
    @gl.uniform4fv(@gl.getUniformLocation(@program, type), product)

  setPerspective:(depth = 10, size = 2.0, xOffset = 0, yOffset = 0) ->
    near = -depth
    far = depth
    left = -size + xOffset
    right = size + xOffset
    ytop = size + yOffset
    bottom = -size + yOffset

    projectionMatrix = ortho(left, right, bottom, ytop, near, far)

    @gl.uniformMatrix4fv(@projectionMatrixLoc, false, flatten(projectionMatrix))


class Part1Canvas extends Canvas
  program_version: '10-1'
  subdivisionLevel: 4
  vertices: [
    vec4(0.0, 0.0, -1.0, 1),
    vec4(0.0, 0.942809, 0.333333, 1),
    vec4(-0.816497, -0.471405, 0.333333, 1),
    vec4(0.816497, -0.471405, 0.333333, 1)
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
  cubeMapImages:
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
    @program = @setupProgram()
    @gl.enable(@gl.DEPTH_TEST)
    # @modelViewMatrixLoc = @gl.getUniformLocation(@program, "modelViewMatrix")
    # @projectionMatrixLoc = @gl.getUniformLocation(@program, "projectionMatrix")

    # @setModelViewMatrix(6.0, @theta, @phi)
    # @setPerspective()

    lightPosition = vec4(10.0, 0.0, 0.0, 0.0 )
    @lightAmbient = vec4(15.0, 15.0, 15.0, 1.0 )
    @lightDiffuse = vec4( 1.0, 1.0, 1.0, 1.0 )
    @lightSpecular = vec4( 1.0, 1.0, 1.0, 1.0 )

    @materialAmbient = vec4( 0.03, 0.03, 0.03, 1.0 )
    @materialDiffuse = vec4( 1.0, 1.0, 1.0, 1.0 )
    @materialSpecular = vec4( 0.0, 0.0, 0.0, 1.0 )
    @materialShininess = 100.0

    @setLightningProduct('ambientProduct', @lightAmbient, @materialAmbient)
    @setLightningProduct('diffuseProduct', @lightDiffuse, @materialDiffuse)
    @setLightningProduct('specularProduct', @lightSpecular, @materialSpecular)
    @gl.uniform4fv(@gl.getUniformLocation(@program, "lightPosition"), flatten(lightPosition))
    @gl.uniform1f(@gl.getUniformLocation(@program, "shininess"), @materialShininess)

    @sphereObject = @loadSphere()

    # @drawTetrahedron()

    # @vBuffer = @createBuffer(flatten(@points))
    # @writeData('vPosition', 4)

    # @nBuffer = @createBuffer(flatten(@normals))
    # @writeData('vNormal', 4)

    @imageLoadCount = 0
    @loadedImages = {}

    for face, texturePath of @cubeMapImages
      image = new Image()
      image.crossOrigin = 'anonymous'
      image.src = texturePath
      image.onload = =>
        @imageLoadCount += 1

        if @imageLoadCount >= 6
          @configureTextureFromCube()

      @cubeMapImages[face] = image

  setupProgram: ->
    program = @loadShaders()
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

    @tetrahedron(@vertices[0], @vertices[1], @vertices[2], @vertices[3], @subdivisionLevel)

    vertexBuffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ARRAY_BUFFER, vertexBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@points), @gl.STATIC_DRAW)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)
    sphereObject.vertexBuffer = vertexBuffer

    normalBuffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ARRAY_BUFFER, normalBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@normals), @gl.STATIC_DRAW)
    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)
    sphereObject.normalBuffer = normalBuffer


    # var cmLeft = document.getElementById("cmLeft");
    # var cmRight = document.getElementById("cmRight");
    # var cmTop = document.getElementById("cmTop");
    # var cmBottom = document.getElementById("cmBottom");
    # var cmBack = document.getElementById("cmBack");
    # var cmFront = document.getElementById("cmFront");

    # var normalMapImage = document.getElementById("normalMap");


    # @gl.activeTexture(@gl.TEXTURE0)

    # cubeMap = @gl.createTexture()

    # @gl.bindTexture(@gl.TEXTURE_CUBE_MAP, cubeMap)
    # @gl.pixelStorei(@gl.UNPACK_FLIP_Y_WEBGL, true)
    # @gl.texImage2D(@gl.TEXTURE_CUBE_MAP_POSITIVE_X, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, cmLeft)
    # @gl.texImage2D(@gl.TEXTURE_CUBE_MAP_NEGATIVE_X, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, cmRight)
    # @gl.texImage2D(@gl.TEXTURE_CUBE_MAP_POSITIVE_Y, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, cmTop)
    # @gl.texImage2D(@gl.TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, cmBottom)
    # @gl.texImage2D(@gl.TEXTURE_CUBE_MAP_POSITIVE_Z, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, cmBack)
    # @gl.texImage2D(@gl.TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, cmFront)
    # @gl.texParameteri(@gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    # @gl.bindTexture(@gl.TEXTURE_CUBE_MAP, null)
    # sphereObject.cubeMap = cubeMap

    # @gl.activeTexture(gl.TEXTURE1);
    # var normalMap = gl.createTexture();
    # gl.bindTexture(gl.TEXTURE_2D, normalMap);
    # gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
    # gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, normalMapImage);
    # gl.generateMipmap(gl.TEXTURE_2D);
    # gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
    # gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    # gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    # gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    # gl.bindTexture(gl.TEXTURE_2D, null);
    # sphereObject.normalMap = normalMap;



    sphereObject.n_vertices = @points.length

    return sphereObject;

  configureTextureFromCube: ->
    @gl.activeTexture(@gl.TEXTURE0)
    cubeMap = @gl.createTexture()
    @gl.bindTexture(@gl.TEXTURE_CUBE_MAP, cubeMap)
    @gl.pixelStorei(@gl.UNPACK_FLIP_Y_WEBGL, true)

    # @gl.texParameteri(@gl.TEXTURE_CUBE_MAP, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE)
    # @gl.texParameteri(@gl.TEXTURE_CUBE_MAP, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE)

    console.log(@cubeMapImages)
    for face, image of @cubeMapImages
      @gl.texImage2D(@gl["TEXTURE_CUBE_MAP_#{face}"], 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, image)

    # @gl.generateMipmap(@gl.TEXTURE_CUBE)

    @gl.texParameteri(@gl.TEXTURE_CUBE_MAP, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
    # @gl.uniform1i(@gl.getUniformLocation(@program, "cubeSampler"), 0)
    @gl.bindTexture(@gl.TEXTURE_CUBE_MAP, null)
    @sphereObject.cubeMap = cubeMap

  drawSphere: ->
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @sphereObject.vertexBuffer)
    @gl.vertexAttribPointer(@program.vPositionLoc, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@program.vPositionLoc)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @sphereObject.normalBuffer)
    @gl.vertexAttribPointer(@program.vNormalLoc, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@program.vNormalLoc)

    @gl.uniformMatrix4fv(@program.modelViewMatrixLoc, false, flatten(@sphereObject.modelViewMatrix))
    @gl.uniformMatrix4fv(@program.projectionMatrixLoc, false, flatten(@sphereObject.projectionMatrix))
    # @gl.uniformMatrix4fv(@program.MtexLoc, false, flatten(@sphereObject.Mtex))
    # @gl.uniform1i(@program.isMirrorLoc, 1)
    # @gl.uniform4fv(@program.eyeLoc,vec4(eye))


    if @sphereObject.cubeMap
      # console.log(@sphereObject.cubeMap)
      @gl.activeTexture(@gl.TEXTURE0)
      @gl.bindTexture(@gl.TEXTURE_CUBE_MAP, @sphereObject.cubeMap)
      @gl.uniform1i(@program.cubeSampler, 0)

    # @gl.activeTexture(@gl.TEXTURE1)
    # @gl.bindTexture(@gl.TEXTURE_2D, @sphereObject.normalMap)
    # @gl.uniform1i(@program.normalSampler, 1)

    @gl.drawArrays(@gl.TRIANGLES, 0, @sphereObject.n_vertices)


  draw: ->
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

    @drawSphere()

    # @setModelViewMatrix(6.0, @theta, @phi)
    # @phi += @speed

    # for i in [0..@points.length - 1] by 3
    #   @gl.drawArrays(@gl.TRIANGLES, i, 3)


window.onload = ->
  new Part1Canvas()

