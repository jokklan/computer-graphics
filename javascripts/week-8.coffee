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

    @gl.viewport(0, 0, @canvas.width, @canvas.height)
    @setBackground()

    @gl.enable(@gl.DEPTH_TEST)

    @setup()

  setup: ->

  draw: ->

  reset: ->
    @points = []
    @colors = []
    @texCoordsArray = [ ]

  setupCanvas: ->
    canvas = @container.getElementsByTagName('canvas')[0]
    WebGLUtils.setupWebGL(canvas)

  setBackground: ->
    @gl.clearColor(0.3921, 0.5843, 0.9294, 1.0)

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
      @points.push(@vertices[vertexIndex])
      @texCoordsArray.push(@texCoords[index])
      @colors.push(@vertexColors[1])


class Part1Canvas extends Canvas
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

  generateTeapotProgram: ->
    @teapotProgram = initShaders(@gl, "#{window.baseurl}/shaders/vshader-8-1-teapot.glsl", "#{window.baseurl}/shaders/fshader-8-1-teapot.glsl")

    @teapotProgram.vPosition  = @gl.getAttribLocation(@teapotProgram, 'vPosition')
    @teapotProgram.vColor     = @gl.getAttribLocation(@teapotProgram, 'vColor')
    @teapotProgram.vNormal    = @gl.getAttribLocation(@teapotProgram, 'vNormal')
    @teapotProgram.projectionMatrix        = @gl.getUniformLocation(@teapotProgram, "projectionMatrix")
    @teapotProgram.modelViewMatrix         = @gl.getUniformLocation(@teapotProgram, "modelViewMatrix")
    @teapotProgram.lightPosition           = @gl.getUniformLocation(@teapotProgram, "lightPosition")

  generateFloorProgram: ->
    @floorProgram = initShaders(@gl, "#{window.baseurl}/shaders/vshader-8-1-floor.glsl", "#{window.baseurl}/shaders/fshader-8-1-floor.glsl")

    @floorProgram.vColor      = @gl.getAttribLocation(@floorProgram, 'vColor')
    @floorProgram.vPosition   = @gl.getAttribLocation(@floorProgram, 'vPosition')
    @floorProgram.vTexCoord   = @gl.getAttribLocation(@floorProgram, 'vTexCoord')
    @floorProgram.texMap            = @gl.getUniformLocation(@floorProgram, "texMap")
    @floorProgram.projectionMatrix       = @gl.getUniformLocation(@floorProgram, "projectionMatrix")
    @floorProgram.modelViewMatrix        = @gl.getUniformLocation(@floorProgram, "modelViewMatrix")

  generateShadowProgram: ->
    @shadowProgram = initShaders(@gl, "#{window.baseurl}/shaders/vshader-8-1-shadow.glsl", "#{window.baseurl}/shaders/fshader-8-1-shadow.glsl")

    @shadowProgram.vPosition   = @gl.getAttribLocation(@shadowProgram, 'vPosition')

    @shadowProgram.projectionMatrix       = @gl.getUniformLocation(@shadowProgram, "projectionMatrix")
    @shadowProgram.modelViewMatrix        = @gl.getUniformLocation(@shadowProgram, "modelViewMatrix")

    @shadowObject = new Object()
    @shadowObject.vertexBuffer = @createEmptyArrayBuffer(@shadowProgram.vPosition, 3, @gl.FLOAT)
    @shadowObject.indexBuffer = @gl.createBuffer()
    @shadowObject.lightVertexBuffer = @createEmptyArrayBuffer(@shadowProgram.vPosition, 3, @gl.FLOAT)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)


  setup: ->
    @perspectiveMatrix = perspective(65.0, 1.0, 0.001, 15.0)
    @g_objDoc = null # The information of OBJ file
    @g_drawinglnfo = null # The information for drawing 3D model

    @quad(0, 1, 2, 3)

    @generateTeapotProgram()
    @generateFloorProgram()
    @generateShadowProgram()

    # Prepare empty buffer objects for vertex coordinates, colors, and normals
    @teapotObject = @initVertexBuffers(@teapotProgram)

    # Start reading the OBJ file
    @readOBJFile("#{window.baseurl}/resources/teapot.obj", 0.25, true)

    @floorObject = new Object()
    @floorObject.vertexBuffer = @createEmptyArrayBuffer(@floorProgram.vPosition, 4, @gl.FLOAT)
    @floorObject.textureBuffer = @createEmptyArrayBuffer(@floorProgram.vTexCoord, 2, @gl.FLOAT)
    @floorObject.colorBuffer = @createEmptyArrayBuffer(@floorProgram.vColor, 4, @gl.FLOAT)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.vertexBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@points), @gl.STATIC_DRAW)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.textureBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@texCoordsArray), @gl.STATIC_DRAW)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.colorBuffer);
    @gl.bufferData(@gl.ARRAY_BUFFER, flatten(@colors), @gl.STATIC_DRAW)

    image = new Image()
    image.crossOrigin = 'anonymous'
    image.onload = =>
      @floorObject.texture = @configureTextureImage(image, 1)

    image.src = "#{window.baseurl}/resources/xamp23.png"

    @tick()

  tick: ->
    @theta += @speed
    if @theta > 2 * Math.PI
      @theta -= 2 * Math.PI

    @draw()
    requestAnimationFrame =>
      @tick()

  getModelViewMatrix: ->
    at = vec3(0.0, 0.0, 0.0)
    up = vec3(0.0, 1.0, 0.0)
    eye = vec3(0.0, 0.0, 1.0)

    modelViewMatrix = lookAt(eye, at, up)
    # modelViewMatrix = mult(modelViewMatrix, rotateX(-90))

  getLightPosition: ->
    vec4(Math.sin(@theta) * 2.0, 2.0, Math.cos(@theta) * 2.0 - 2.0, 0.0)
    # vec4(0.0, 2.0, 2.0, 0.0)

  getModelViewMatrixForObject: ->
    modelViewMatrix = @getModelViewMatrix()
    y = Math.sin(@theta) / 3.0 - 0.5
    modelViewMatrix = mult(modelViewMatrix, translate(0.0, y, -3.0, 0.0))

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
    @teapotObject.modelViewMatrix = @getModelViewMatrixForObject()

    @gl.uniformMatrix4fv(@teapotProgram.projectionMatrix, false, flatten(@teapotObject.projectionMatrix));
    @gl.uniformMatrix4fv(@teapotProgram.modelViewMatrix, false, flatten(@teapotObject.modelViewMatrix));
    @gl.uniform4fv(@teapotProgram.lightPosition, flatten(@getLightPosition()));

    @gl.drawElements(@gl.TRIANGLES, @g_drawingInfo.indices.length, @gl.UNSIGNED_SHORT, 0)

  drawfloor: ->
    @gl.useProgram(@floorProgram)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.vertexBuffer)
    @gl.vertexAttribPointer(@floorProgram.vPosition, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@floorProgram.vPosition)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.colorBuffer)
    @gl.vertexAttribPointer(@floorProgram.vColor, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@floorProgram.vColor)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.textureBuffer)
    @gl.vertexAttribPointer(@floorProgram.vTexCoord, 2, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@floorProgram.vTexCoord)

    @gl.activeTexture(@gl.TEXTURE0)
    @gl.bindTexture(@gl.TEXTURE_2D, @floorObject.texture)
    @gl.uniform1i(@floorProgram.texMap, 0)

    @floorObject.projectionMatrix = @perspectiveMatrix
    @floorObject.modelViewMatrix = @getModelViewMatrix()

    @gl.uniformMatrix4fv(@floorProgram.projectionMatrix, false, flatten(@floorObject.projectionMatrix))
    @gl.uniformMatrix4fv(@floorProgram.modelViewMatrix, false, flatten(@floorObject.modelViewMatrix))

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

    lightPosition = @getLightPosition()

    # Rotate shadow
    shadowProjection = mat4()
    shadowProjection[3][3] = 0.0
    shadowProjection[3][1] = -1.0 / (lightPosition[1] + 1.0 + (Math.sin(@theta) / 3.0 - 0.5) + 1.0)

    # Model-view matrix for shadow
    modelViewMatrix = @getModelViewMatrixForObject()
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

    @drawfloor()
    @drawShadows()
    @drawTeapot()

class Part2Canvas extends Part1Canvas
  constructor: (selector = 'part_2')->
    super(selector)

  generateShadowProgram: ->
    @shadowProgram = initShaders(@gl, "#{window.baseurl}/shaders/vshader-8-2-shadow.glsl", "#{window.baseurl}/shaders/fshader-8-2-shadow.glsl")

    @shadowProgram.vPosition   = @gl.getAttribLocation(@shadowProgram, 'vPosition')

    @shadowProgram.projectionMatrix       = @gl.getUniformLocation(@shadowProgram, "projectionMatrix")
    @shadowProgram.modelViewMatrix        = @gl.getUniformLocation(@shadowProgram, "modelViewMatrix")

    @shadowObject = new Object()
    @shadowObject.vertexBuffer = @createEmptyArrayBuffer(@shadowProgram.vPosition, 3, @gl.FLOAT)
    @shadowObject.indexBuffer = @gl.createBuffer()
    @shadowObject.textureWidth = 1024
    @shadowObject.textureHeight = 1024

    @shadowObject.framebuffer = @initFramebufferObject()

    @gl.bindBuffer(@gl.ARRAY_BUFFER, null)

  generateFloorProgram: ->
    @floorProgram = initShaders(@gl, "#{window.baseurl}/shaders/vshader-8-2-floor.glsl", "#{window.baseurl}/shaders/fshader-8-2-floor.glsl")

    @floorProgram.vColor      = @gl.getAttribLocation(@floorProgram, 'vColor')
    @floorProgram.vPosition   = @gl.getAttribLocation(@floorProgram, 'vPosition')
    @floorProgram.vTexCoord   = @gl.getAttribLocation(@floorProgram, 'vTexCoord')
    @floorProgram.texMap            = @gl.getUniformLocation(@floorProgram, "texMap")
    @floorProgram.shadowMap            = @gl.getUniformLocation(@floorProgram, "shadowMap")
    @floorProgram.projectionMatrix       = @gl.getUniformLocation(@floorProgram, "projectionMatrix")
    @floorProgram.modelViewMatrix        = @gl.getUniformLocation(@floorProgram, "modelViewMatrix")
    @floorProgram.projectionMatrixFromLight       = @gl.getUniformLocation(@floorProgram, "projectionMatrixFromLight")
    @floorProgram.modelViewMatrixFromLight        = @gl.getUniformLocation(@floorProgram, "modelViewMatrixFromLight")

  getModelViewMatrixFromLight: ->
    lightPosition = @getLightPosition()

    # at = vec3(0.0, Math.sin(@theta) / 3.0 - 0.5, -3.0)
    at = vec3(0.0, 0.0, 0.0)
    up = vec3(0.0, 1.0, 0.0)
    eye = vec3(lightPosition[0], lightPosition[1], lightPosition[2])

    modelViewMatrix = lookAt(eye, at, up)
    # mult(modelViewMatrix, translate(0.0, Math.sin(@theta) / 3.0 - 0.5, -3.0, 0.0))



  drawShadows: ->
    # @gl.bindFramebuffer(@gl.FRAMEBUFFER, @shadowObject.framebuffer)
    @gl.useProgram(@shadowProgram)

    # Use shadow program and buffers with depth and blend functions
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @shadowObject.vertexBuffer)
    @gl.vertexAttribPointer(@shadowProgram.vPosition, 3, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@shadowProgram.vPosition)

    # Model-view matrix for shadow
    @gl.uniformMatrix4fv(@shadowProgram.projectionMatrix, false, flatten(@perspectiveMatrix))
    @gl.uniformMatrix4fv(@shadowProgram.modelViewMatrix, false, flatten(@getModelViewMatrixFromLight()))

    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @shadowObject.indexBuffer)
    # Draw shadows
    @gl.drawElements(@gl.TRIANGLES, @g_drawingInfo.indices.length, @gl.UNSIGNED_SHORT, 0)

    # # Disable blend and depth functions
    # @gl.bindFramebuffer(@gl.FRAMEBUFFER, null)

  drawfloor: ->
    @gl.useProgram(@floorProgram)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.vertexBuffer)
    @gl.vertexAttribPointer(@floorProgram.vPosition, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@floorProgram.vPosition)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.colorBuffer)
    @gl.vertexAttribPointer(@floorProgram.vColor, 4, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@floorProgram.vColor)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @floorObject.textureBuffer)
    @gl.vertexAttribPointer(@floorProgram.vTexCoord, 2, @gl.FLOAT, false, 0, 0)
    @gl.enableVertexAttribArray(@floorProgram.vTexCoord)

    @gl.activeTexture(@gl.TEXTURE0)
    @gl.bindTexture(@gl.TEXTURE_2D, @shadowObject.framebuffer.texture)
    @gl.uniform1i(@floorProgram.shadowMap, 0)

    @gl.activeTexture(@gl.TEXTURE1)
    @gl.bindTexture(@gl.TEXTURE_2D, @floorObject.texture)
    @gl.uniform1i(@floorProgram.texMap, 1)

    @gl.uniformMatrix4fv(@floorProgram.projectionMatrix, false, flatten(@perspectiveMatrix))
    @gl.uniformMatrix4fv(@floorProgram.modelViewMatrix, false, flatten(@getModelViewMatrix()))

    @gl.uniformMatrix4fv(@floorProgram.projectionMatrixFromLight, false, flatten(@perspectiveMatrix))
    @gl.uniformMatrix4fv(@floorProgram.modelViewMatrixFromLight, false, flatten(@getModelViewMatrixFromLight()))

    @gl.drawArrays(@gl.TRIANGLES, 0, 6)

  draw: ->
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT) # Clear color and depth buffers

    if @g_objDoc != null && @g_objDoc.isMTLComplete() # OBJ and all MTLs are available
      @g_drawingInfo = @onReadComplete()
      @g_objDoc = null
    if (!@g_drawingInfo)
      return null

    @gl.bindFramebuffer(@gl.FRAMEBUFFER, @shadowObject.framebuffer)
    @gl.viewport(0, 0, @shadowObject.textureWidth, @shadowObject.textureHeight);
    @drawShadows()
    @gl.bindFramebuffer(@gl.FRAMEBUFFER, null)
    @gl.viewport(0, 0, @canvas.width, @canvas.height);
    @drawShadows()
    @drawTeapot()
    @drawfloor()

  initFramebufferObject: ->

    # Define the error handling function
    error = ->
      if framebuffer then @gl.deleteFramebuffer(framebuffer)
      if texture then @gl.deleteTexture(texture)
      if renderBuffer then @gl.deleteRenderbuffer(renderBuffer)
      return null

    # Create a framebuffer object (FBO)
    framebuffer = @gl.createFramebuffer()
    if !framebuffer
      console.log('Failed to create frame buffer object')
      return error()

    # Create a texture object and set its size and parameters
    texture = @gl.createTexture() # Create a texture object
    if !texture
      console.log('Failed to create texture object')
      return error()

    @gl.bindTexture(@gl.TEXTURE_2D, texture)
    @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @shadowObject.textureWidth, @shadowObject.textureHeight, 0, @gl.RGBA, @gl.UNSIGNED_BYTE, null)
    @gl.generateMipmap(@gl.TEXTURE_2D);
    # @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR);
    # @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR_MIPMAP_NEAREST);

    @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR);
    # @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR);
    # @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR);

    # Create a renderbuffer object and Set its size and parameters
    renderBuffer = @gl.createRenderbuffer() # Create a renderbuffer object
    if !renderBuffer
      console.log('Failed to create renderbuffer object')
      return error()

    @gl.bindRenderbuffer(@gl.RENDERBUFFER, renderBuffer)
    @gl.renderbufferStorage(@gl.RENDERBUFFER, @gl.DEPTH_COMPONENT16, @shadowObject.textureWidth, @shadowObject.textureHeight)

    # Attach the texture and the renderbuffer object to the FBO
    @gl.bindFramebuffer(@gl.FRAMEBUFFER, framebuffer)
    @gl.framebufferTexture2D(@gl.FRAMEBUFFER, @gl.COLOR_ATTACHMENT0, @gl.TEXTURE_2D, texture, 0)
    @gl.framebufferRenderbuffer(@gl.FRAMEBUFFER, @gl.DEPTH_ATTACHMENT, @gl.RENDERBUFFER, renderBuffer)

    # Check if FBO is configured correctly
    status = @gl.checkFramebufferStatus(@gl.FRAMEBUFFER)
    if @gl.FRAMEBUFFER_COMPLETE != status
      console.log('Frame buffer object is incomplete: ' + status.toString())
      return error()

    framebuffer.texture = texture # keep the required object

    # Unbind the buffer object
    @gl.bindFramebuffer(@gl.FRAMEBUFFER, null)
    @gl.bindTexture(@gl.TEXTURE_2D, null)
    @gl.bindRenderbuffer(@gl.RENDERBUFFER, null)

    return framebuffer

window.onload = ->
  new Part1Canvas()
  new Part2Canvas()
