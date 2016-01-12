---
---
class Canvas
  theta: 0.0
  speed: 0.05

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

  setup: ->

  draw: ->

  reset: ->
    @floorPoints = []
    @spherePoints = []
    @floorColors = []
    @sphereColors = []
    @floorTexCoordsArray = [ ]

  setupCanvas: ->
    canvas = @container.getElementsByTagName('canvas')[0]
    WebGLUtils.setupWebGL(canvas)

  setBackground: ->
    @gl.clearColor(0.2, 0.2, 0.2, 1.0)

  loadShaders: ->
    program = initShaders(@gl, "#{window.baseurl}/shaders/vshader-#{@program_version}.glsl", "#{window.baseurl}/shaders/fshader-#{@program_version}.glsl")
    @gl.useProgram(program)
    program

  createBuffer: (data) ->
    buffer = @gl.createBuffer()
    @gl.bindBuffer(@gl.ARRAY_BUFFER, buffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, data, @gl.STATIC_DRAW)
    buffer

  writeData: (attribute, pointerSize, program) ->
    vAttribute = @gl.getAttribLocation(program, attribute)
    @gl.vertexAttribPointer(vAttribute, pointerSize, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(vAttribute)

  # Create a buffer object and perform the initial configuration
  initVertexBuffers: (program)->
    obj = new Object()
    obj.vertexBuffer = @createEmptyArrayBuffer(program.vPosition, 3, @gl.FLOAT)
    obj.normalBuffer = @createEmptyArrayBuffer(program.vNormal, 3, @gl.FLOAT)
    obj.colorBuffer = @createEmptyArrayBuffer(program.vColor, 4, @gl.FLOAT)
    obj.indexBuffer = @gl.createBuffer()

    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)

    return obj

  # Create a buffer object, assign it to attribute variables, and enable the assignment
  createEmptyArrayBuffer: (v_attribute, num, type) ->
    buffer = @gl.createBuffer() # Create a buffer object

    @gl.bindBuffer(@gl.ARRAY_BUFFER, buffer)
    @gl.vertexAttribPointer(v_attribute, num, type, false, 0, 0);
    @gl.enableVertexAttribArray(v_attribute); # Enable the assignment

    buffer

  onReadComplete: ->
    # Acquire the vertex coordinates and colors from OBJ file
    drawingInfo = @g_objDoc.getDrawingInfo()

    # Write date into the buffer object
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @teapotObject.vertexBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, drawingInfo.vertices, @gl.STATIC_DRAW)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @teapotObject.normalBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, drawingInfo.normals, @gl.STATIC_DRAW)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @teapotObject.colorBuffer);
    @gl.bufferData(@gl.ARRAY_BUFFER, drawingInfo.colors, @gl.STATIC_DRAW)

    # Write the indices to the buffer object
    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @teapotObject.indexBuffer)
    @gl.bufferData(@gl.ELEMENT_ARRAY_BUFFER, drawingInfo.indices, @gl.STATIC_DRAW)

    # Write data into the shadow buffer object
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @shadowObject.vertexBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, drawingInfo.vertices, @gl.STATIC_DRAW)

    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @shadowObject.indexBuffer)
    @gl.bufferData(@gl.ELEMENT_ARRAY_BUFFER, drawingInfo.indices, @gl.STATIC_DRAW)

    return drawingInfo

  # Read a file
  readOBJFile: (fileName, scale, reverse) ->
    request = new XMLHttpRequest()

    request.onreadystatechange = =>
      if request.readyState == 4 && request.status != 404
        @onReadOBJFile(request.responseText, fileName, scale, reverse)

    request.open('GET', fileName, true) # Create a request to get file
    request.send() # Send the request

  # OBJ file has been read
  onReadOBJFile: (fileString, fileName, scale, reverse) ->
    objDoc = new OBJDoc(fileName) # Create a OBJDoc object
    result = objDoc.parse(fileString, scale, reverse)
    if !result
      @g_objDoc = null
      @g_drawinglnfo = null
      console.log("OBJ file parsing error.")
      return

    @g_objDoc = objDoc

  configureTextureImage: (image, textureIndex = 0)->
    @gl.activeTexture(@gl["TEXTURE#{textureIndex}"]);
    texture = @gl.createTexture()
    @gl.bindTexture(@gl.TEXTURE_2D, texture)
    @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGB, @gl.RGB, @gl.UNSIGNED_BYTE, image)
    # @gl.generateMipmap(@gl.TEXTURE_2D)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
    return texture;

  configureTextureArray: (texSize, image, textureIndex = 0)->
    @gl.activeTexture(@gl["TEXTURE#{textureIndex}"]);
    texture = @gl.createTexture()
    @gl.bindTexture(@gl.TEXTURE_2D, texture)
    @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, texSize, texSize, 0, @gl.RGBA, @gl.UNSIGNED_BYTE, image)
    # @gl.generateMipmap(@gl.TEXTURE_2D)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.REPEAT)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
    return texture;

  writeTexture: (index)->
    @gl.uniform1i(@floorProgram.texMap, index)

  quad: (a, b, c, d) ->
    vertexIndices = [a, b, c, d]
    indices = [0, 1, 2, 0, 2, 3]

    for index in indices
      vertexIndex = vertexIndices[index]
      @floorPoints.push(@floorVertices[vertexIndex])
      @floorTexCoordsArray.push(@texCoords[index])
      @floorColors.push(@vertexColors[1])

  drawTetrahedron: (subdivisionLevel, offset = [0,0,0,0], color = vec4())->
    @tetrahedron(@sphereVertices[0], @sphereVertices[1], @sphereVertices[2], @sphereVertices[3], subdivisionLevel, offset, color)

  tetrahedron: (a, b, c, d, n, offset, color) ->
    @divideTriangle(a, b, c, n, offset, color)
    @divideTriangle(d, c, b, n, offset, color)
    @divideTriangle(a, d, b, n, offset, color)
    @divideTriangle(a, c, d, n, offset, color)

  divideTriangle: (a, b, c, count, offset, color) ->
    if count > 0
      ab = normalize(mix(a, b, 0.5), true)
      ac = normalize(mix(a, c, 0.5), true)
      bc = normalize(mix(b, c, 0.5), true)

      @divideTriangle(a, ab, ac, count - 1, offset, color)
      @divideTriangle(ab, b, bc, count - 1, offset, color)
      @divideTriangle(bc, c, ac, count - 1, offset, color)
      @divideTriangle(ab, bc, ac, count - 1, offset, color)
    else
      @triangle(a, b, c, offset, color)

  triangle: (a, b, c, offset, color)->
    scale = 0.1
    scaleVector = vec4(scale, scale, scale)
    @spherePoints.push(mult(add(a,offset), scaleVector))
    @spherePoints.push(mult(add(b,offset), scaleVector))
    @spherePoints.push(mult(add(c,offset), scaleVector))
    @sphereColors.push(color)
    @sphereColors.push(color)
    @sphereColors.push(color)


class Part1Canvas extends Canvas
  subdivisionLevel: 4
  canvasHeight: 1024
  canvasWidth: 1024
  floorVertices: [
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
  sphereVertices: [
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
    vec2(0.0, 0.0),
    vec2(0.0, 1.0),
    vec2(1.0, 1.0),
    vec2(1.0, 0.0)
  ]

  constructor: (selector = 'part_1')->
    super(selector)

  generateTeapotProgram: ->
    program = initShaders(@gl, "#{window.baseurl}/shaders/vshader-project-object.glsl", "#{window.baseurl}/shaders/fshader-project-object.glsl")

    program.vPosition  = @gl.getAttribLocation(program, 'vPosition')
    program.vColor     = @gl.getAttribLocation(program, 'vColor')
    program.vNormal    = @gl.getAttribLocation(program, 'vNormal')
    program.projectionMatrix        = @gl.getUniformLocation(program, "projectionMatrix")
    program.modelViewMatrix         = @gl.getUniformLocation(program, "modelViewMatrix")
    program.lightPosition           = @gl.getUniformLocation(program, "lightPosition")
    program.ambientProduct          = @gl.getUniformLocation(program, 'ambientProduct')
    program.materialDiffuse          = @gl.getUniformLocation(program, 'materialDiffuse')
    program.lightDiffuse          = @gl.getUniformLocation(program, 'lightDiffuse')
    # program.specularProduct         = @gl.getUniformLocation(program, 'specularProduct')
    # program.materialShininess       = @gl.getUniformLocation(program, 'shininess')

    return program

  generateLightProgram: ->
    program = initShaders(@gl, "#{window.baseurl}/shaders/vshader-project-light.glsl", "#{window.baseurl}/shaders/fshader-project-light.glsl")

    program.vPosition  = @gl.getAttribLocation(program, 'vPosition')
    program.vColor     = @gl.getAttribLocation(program, 'vColor')
    program.projectionMatrix        = @gl.getUniformLocation(program, "projectionMatrix")
    program.modelViewMatrix         = @gl.getUniformLocation(program, "modelViewMatrix")
    program.lightPosition           = @gl.getUniformLocation(program, "lightPosition")

    return program

  generateFloorProgram: ->
    program = initShaders(@gl, "#{window.baseurl}/shaders/vshader-8-1-floor.glsl", "#{window.baseurl}/shaders/fshader-8-1-floor.glsl")

    program.vColor      = @gl.getAttribLocation(program, 'vColor')
    program.vPosition   = @gl.getAttribLocation(program, 'vPosition')
    program.vTexCoord   = @gl.getAttribLocation(program, 'vTexCoord')
    program.texMap            = @gl.getUniformLocation(program, "texMap")
    program.projectionMatrix       = @gl.getUniformLocation(program, "projectionMatrix")
    program.modelViewMatrix        = @gl.getUniformLocation(program, "modelViewMatrix")

    return program

  generateShadowProgram: ->
    program = initShaders(@gl, "#{window.baseurl}/shaders/vshader-8-1-shadow.glsl", "#{window.baseurl}/shaders/fshader-8-1-shadow.glsl")

    program.vPosition   = @gl.getAttribLocation(program, 'vPosition')

    program.projectionMatrix       = @gl.getUniformLocation(program, "projectionMatrix")
    program.modelViewMatrix        = @gl.getUniformLocation(program, "modelViewMatrix")

    @shadowObject = new Object()
    @shadowObject.vertexBuffer = @createEmptyArrayBuffer(program.vPosition, 3, @gl.FLOAT)
    @shadowObject.indexBuffer = @gl.createBuffer()

    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)
    return program


  setup: ->
    @perspectiveMatrix = perspective(90.0, 1.0, 0.1, 100.0)
    @rotationMatrix = mat4()
    @zoom = 7.0
    @g_objDoc = null # The information of OBJ file
    @g_drawinglnfo = null # The information for drawing 3D model

    @quad(0, 1, 2, 3)

    @teapotProgram = @generateTeapotProgram()
    @lightProgram = @generateLightProgram()
    @floorProgram = @generateFloorProgram()
    @shadowProgram = @generateShadowProgram()

    # Prepare empty buffer objects for vertex coordinates, colors, and normals
    @teapotObject = @initVertexBuffers(@teapotProgram)

    lightAmbient = vec4(1.0, 1.0, 1.0, 1.0 )
    # lightSpecular = vec4( 1.0, 1.0, 1.0, 1.0 )

    materialAmbient = vec4( 0.1, 0.1, 0.1, 1.0 )
    materialDiffuse = vec4( 1.0, 1.0, 1.0, 1.0 )
    # materialSpecular = vec4( 0.5, 0.5, 0.5, 1.0 )

    # materialShininess = 100.0

    @teapotObject.ambientProduct =  mult(lightAmbient, materialAmbient)
    # @teapotObject.specularProduct =  mult(lightSpecular, materialSpecular)
    @teapotObject.materialDiffuse = materialDiffuse
    # @teapotObject.materialShininess =  materialShininess
    @teapotObject.lightDiffuse = @getLightColors()


    @lightObject = new Object()
    @lightObject.vertexBuffer = @createEmptyArrayBuffer(@lightProgram.vPosition, 4, @gl.FLOAT)
    @lightObject.colorBuffer = @createEmptyArrayBuffer(@lightProgram.vColor, 4, @gl.FLOAT)

    # Start reading the OBJ file
    # @readOBJFile("#{window.baseurl}/resources/project/box_with_character.obj", 0.0005, true)
    @readOBJFile("#{window.baseurl}/resources/teapot.obj", 0.60, true)

    @floorObject = new Object()
    @floorObject.vertexBuffer = @createEmptyArrayBuffer(@floorProgram.vPosition, 4, @gl.FLOAT)
    @floorObject.textureBuffer = @createEmptyArrayBuffer(@floorProgram.vTexCoord, 2, @gl.FLOAT)
    @floorObject.colorBuffer = @createEmptyArrayBuffer(@floorProgram.vColor, 4, @gl.FLOAT)

    image = new Image()
    image.crossOrigin = 'anonymous'
    image.onload = =>
      @floorObject.texture = @configureTextureImage(image, 0)

    image.src = "#{window.baseurl}/resources/xamp23.png"
    @setupInteractions()

    @tick()

  setupInteractions: ->
    @mouseDown = false
    @deltaMouseX = 0
    @deltaMouseY = 0

    @canvas.onmousedown = (event)=> @handleMouseDown(event)
    document.onmouseup = (event)=> @handleMouseUp(event)
    document.onmousemove = (event)=> @handleMouseMove(event)
    window.onkeydown = (event)=> @onKeyDown(event)

  handleMouseDown: (event)->
    @mouseDown = true
    @lastMouseX = event.clientX
    @lastMouseY = event.clientY

  handleMouseUp: (event)->
    @mouseDown = false

  handleMouseMove: (event) ->
    if !@mouseDown
      return

    newX = event.clientX
    newY = event.clientY

    @deltaMouseX += newX - @lastMouseX
    @deltaMouseY += newY - @lastMouseY

    if @deltaMouseX > @canvasWidth
      @deltaMouseX -= @canvasWidth

    if @deltaMouseX < 0
      @deltaMouseX += @canvasWidth

    if @deltaMouseY > @canvasHeight
      @deltaMouseY -= @canvasHeight

    if @deltaMouseY < 0
      @deltaMouseY += @canvasHeight


    scale = (360.0 / @canvasHeight)
    @rotationMatrix = mult(rotateX(- @deltaMouseY * scale), rotateY(- @deltaMouseX * scale))

    @lastMouseX = newX
    @lastMouseY = newY

  onKeyDown: (event)->
    switch event.keyCode
      when 187 then @zoom -= 1.0 # +
      when 189 then @zoom += 1.0 # -

  tick: ->
    @theta += @speed
    # if @theta > 2 * Math.PI
    #   @theta -= 2 * Math.PI

    @draw()
    requestAnimationFrame =>
      @tick()

  getModelViewMatrix: ->
    at = vec3(0.0, 0.0, 0.0)
    up = vec3(0.0, 1.0, 0.0)
    eye = vec3(0.0, @zoom, @zoom)

    modelViewMatrix = lookAt(eye, at, up)
    modelViewMatrix = mult(modelViewMatrix, @rotationMatrix)

  getLightPositions: ->
    radius = 50.0
    center = [0, 0, 0]
    offset = Math.PI * 2
    [
      @addLight([1, 0, 0], [0, 1, 1], center, radius, 0.0 * offset, 1.0),
      @addLight([0, 1, 0], [1, 0, 1], center, radius, 0.1 * offset, 1.2)
      @addLight([0, 0, 1], [1, 1, 0], center, radius, 0.2 * offset, 1.4)
      @addLight([1, 1, 0], [0, 0, 1], center, radius, 0.3 * offset, 1.6)
      @addLight([1, 0, 1], [0, 1, 0], center, radius, 0.4 * offset, 1.8)
      @addLight([0, 1, 1], [1, 0, 0], center, radius, 0.5 * offset, 2.0)
    ]

  addLight: (a, b, center, radius, offset, speed)->
    theta = (@theta + offset) * speed
    [
      center[0] + radius * Math.cos(theta) * a[0] + radius * Math.sin(theta) * b[0],
      center[1] + radius * Math.cos(theta) * a[1] + radius * Math.sin(theta) * b[1],
      center[2] + radius * Math.cos(theta) * a[2] + radius * Math.sin(theta) * b[2],
      0.0
    ]

  getLightColors: ->
    [
      vec4( 1.0, 0.0, 0.0, 1.0 ),
      vec4( 0.0, 1.0, 0.0, 1.0 ),
      vec4( 0.0, 0.0, 1.0, 1.0 ),
      vec4( 0.0, 1.0, 1.0, 1.0 ),
      vec4( 1.0, 0.0, 1.0, 1.0 ),
      vec4( 1.0, 1.0, 0.0, 1.0 ),
    ]


  drawTeapot: ->
    @gl.useProgram(@teapotProgram)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @teapotObject.vertexBuffer)
    @gl.vertexAttribPointer(@teapotProgram.vPosition, 3, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@teapotProgram.vPosition)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @teapotObject.normalBuffer)
    @gl.vertexAttribPointer(@teapotProgram.vNormal, 3, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@teapotProgram.vNormal)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @teapotObject.colorBuffer)
    @gl.vertexAttribPointer(@teapotProgram.vColor, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@teapotProgram.vColor)

    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @teapotObject.indexBuffer)

    @teapotObject.projectionMatrix = @perspectiveMatrix
    @teapotObject.modelViewMatrix = @getModelViewMatrix()

    @gl.uniformMatrix4fv(@teapotProgram.projectionMatrix, false, flatten(@teapotObject.projectionMatrix));
    @gl.uniformMatrix4fv(@teapotProgram.modelViewMatrix, false, flatten(@teapotObject.modelViewMatrix));
    @gl.uniform4fv(@teapotProgram.lightPosition, flatten(@getLightPositions()));

    @gl.uniform4fv(@teapotProgram.ambientProduct, @teapotObject.ambientProduct)
    @gl.uniform4fv(@teapotProgram.materialDiffuse, @teapotObject.materialDiffuse)
    @gl.uniform4fv(@teapotProgram.lightDiffuse, flatten(@teapotObject.lightDiffuse))
    # @gl.uniform4fv(@teapotProgram.specularProduct, @teapotObject.specularProduct)
    # @gl.uniform1f(@teapotProgram.materialShininess, @teapotObject.materialShininess)

    @gl.drawElements(@gl.TRIANGLES, @g_drawingInfo.indices.length, @gl.UNSIGNED_SHORT, 0)

  drawLights: ->
    @gl.useProgram(@lightProgram)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @lightObject.vertexBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@spherePoints), @gl.STATIC_DRAW)
    @gl.vertexAttribPointer(@lightProgram.vPosition, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@lightProgram.vPosition)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @lightObject.colorBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@sphereColors), @gl.STATIC_DRAW)
    @gl.vertexAttribPointer(@lightProgram.vColor, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@lightProgram.vColor)

    @gl.uniformMatrix4fv(@lightProgram.projectionMatrix, false, flatten(@perspectiveMatrix));
    @gl.uniformMatrix4fv(@lightProgram.modelViewMatrix, false, flatten(@getModelViewMatrix()));

    for i in [0..@spherePoints.length - 1] by 3
      @gl.drawArrays(@gl.TRIANGLES, i, 3)

  drawfloor: ->
    @gl.useProgram(@floorProgram)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.vertexBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@floorPoints), @gl.STATIC_DRAW)
    @gl.vertexAttribPointer(@floorProgram.vPosition, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@floorProgram.vPosition)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.colorBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@floorColors), @gl.STATIC_DRAW)
    @gl.vertexAttribPointer(@floorProgram.vColor, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@floorProgram.vColor)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.textureBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@floorTexCoordsArray), @gl.STATIC_DRAW)
    @gl.vertexAttribPointer(@floorProgram.vTexCoord, 2, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@floorProgram.vTexCoord)

    @gl.activeTexture(@gl.TEXTURE0)
    @gl.bindTexture(@gl.TEXTURE_2D, @floorObject.texture)
    @gl.uniform1i(@floorProgram.texMap, 0)
    @gl.uniform1i(@floorProgram.shadowMap, 1)

    @gl.uniformMatrix4fv(@floorProgram.projectionMatrix, false, flatten(@perspectiveMatrix))
    @gl.uniformMatrix4fv(@floorProgram.modelViewMatrix, false, flatten(@getModelViewMatrix()))

    @gl.drawArrays(@gl.TRIANGLES, 0, 6)

  drawShadows: (modelViewMatrix, offset = 0.0001)->
    # Use shadow program and buffers with depth and blend functions
    @gl.useProgram(@shadowProgram)

    @gl.enable(@gl.BLEND)
    @gl.blendFunc(@gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA)
    @gl.depthFunc(@gl.GREATER)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @shadowObject.vertexBuffer)
    @gl.vertexAttribPointer(@shadowProgram.vPosition, 3, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@shadowProgram.vPosition)

    # Rotate shadow
    lightPosition = @getLightPositions()[1]
    shadowProjection = mat4()
    shadowProjection[3][3] = 0.0
    shadowProjection[3][1] = -1.0/(lightPosition[1] + 1.0 + 0.01)

    # Model-view matrix for shadow
    modelViewMatrix = @getModelViewMatrix()
    modelViewMatrix = mult(modelViewMatrix, translate(lightPosition[0], lightPosition[1], lightPosition[2]))
    modelViewMatrix = mult(modelViewMatrix, shadowProjection)
    modelViewMatrix = mult(modelViewMatrix, translate(-lightPosition[0], -lightPosition[1], -lightPosition[2]))

    @gl.uniformMatrix4fv(@shadowProgram.projectionMatrix, false, flatten(@perspectiveMatrix))
    @gl.uniformMatrix4fv(@shadowProgram.modelViewMatrix, false, flatten(modelViewMatrix))

    # Draw shadows
    @gl.drawElements(@gl.TRIANGLES, @g_drawingInfo.indices.length, @gl.UNSIGNED_SHORT, 0)

    # Disable blend and depth functions
    @gl.disable(@gl.BLEND)
    @gl.depthFunc(@gl.LESS)

  draw: ->
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT) # Clear color and depth buffers

    if @g_objDoc != null && @g_objDoc.isMTLComplete() # OBJ and all MTLs are available
      @g_drawingInfo = @onReadComplete()
      @g_objDoc = null
    if (!@g_drawingInfo)
      return

    @spherePoints = []
    @sphereColors = []

    colors = @getLightColors()
    for pos, index in @getLightPositions()
      @drawTetrahedron(4, pos, colors[index])

    # @drawfloor()
    # @drawShadows()
    @drawTeapot()
    @drawLights()

window.onload = ->
  new Part1Canvas()
