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

    @program = @loadShaders()

    @gl.enable(@gl.DEPTH_TEST)

    @setup()
    # @draw()
    # @render()

  setup: ->

  draw: ->

  reset: ->

  setupCanvas: ->
    canvas = @container.getElementsByTagName('canvas')[0]
    WebGLUtils.setupWebGL(canvas)

  setBackground: ->
    @gl.clearColor(0.3921, 0.5843, 0.9294, 1.0)

  # createBuffer: (data) ->
  #   buffer = @gl.createBuffer()
  #   @gl.bindBuffer(@gl.ARRAY_BUFFER, buffer)
  #   @gl.bufferData(@gl.ARRAY_BUFFER, data, @gl.STATIC_DRAW)
  #   buffer

  # writeData: (attribute, pointerSize) ->
  #   vAttribute = @gl.getAttribLocation(@program, attribute)
  #   @gl.vertexAttribPointer(vAttribute, pointerSize, @gl.FLOAT, false, 0, 0)
  #   @gl.enableVertexAttribArray(vAttribute)

  loadShaders: ->
    program = initShaders(@gl, "/shaders/vshader-#{@program_version}.glsl", "/shaders/fshader-#{@program_version}.glsl")
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

  setLightningProduct: (type, light, material)->
    product = mult(light, material)
    @gl.uniform4fv(@gl.getUniformLocation(@program, type), product)

  # render: () ->
  #   @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

  #   @gl.drawElements(@gl.TRIANGLES, numVertices, @gl.UNSIGNED_BYTE, 0)

class Part3Canvas extends Canvas
  program_version: '5-3'

  constructor: (selector = 'part_3')->
    super(selector)

  setup: ->
    @g_objDoc = null # The information of OBJ file
    @g_drawinglnfo = null # The information for drawing 3D model

    # Get the storage locations of attribute and uniform variables
    @program.vPosition  = @gl.getAttribLocation(@program, 'vPosition')
    @program.vNormal    = @gl.getAttribLocation(@program, 'vNormal')
    @program.vColor     = @gl.getAttribLocation(@program, 'vColor')

    # Prepare empty buffer objects for vertex coordinates, colors, and normals
    @model = @initVertexBuffers()

    # Start reading the OBJ file
    @readOBJFile('/resources/teapot.obj', 0.3, true)

    @modelViewMatrixLoc = @gl.getUniformLocation(@program, "modelViewMatrix")
    @projectionMatrixLoc = @gl.getUniformLocation(@program, "projectionMatrix")
    @lightPosition = @gl.getUniformLocation(@program, "lightPosition")

    @setModelViewMatrix(1)
    @setPerspective(10)
    lightPosition = vec4(1.0, 1.0, 1.0, 0.0)
    @gl.uniform4fv(@lightPosition, flatten(lightPosition))

    @tick()

  tick: ->
    @draw()
    requestAnimationFrame =>
      @tick()


  # Create a buffer object and perform the initial configuration
  initVertexBuffers: ->
    obj = new Object()
    obj.vertexBuffer = @createEmptyArrayBuffer(@program.vPosition, 3, @gl.FLOAT)
    obj.normalBuffer = @createEmptyArrayBuffer(@program.vNormal, 3, @gl.FLOAT)
    obj.colorBuffer = @createEmptyArrayBuffer(@program.vColor, 4, @gl.FLOAT)
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


  draw: ->
    if @g_objDoc != null && @g_objDoc.isMTLComplete() # OBJ and all MTLs are available
      @g_drawingInfo = @onReadComplete()
      @g_objDoc = null
    if (!@g_drawingInfo)
      return

    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT) # Clear color and depth buffers

    # Draw
    @gl.drawElements(@gl.TRIANGLES, @g_drawingInfo.indices.length, @gl.UNSIGNED_SHORT, 0)


  onReadComplete: ->
    # Acquire the vertex coordinates and colors from OBJ file
    drawingInfo = @g_objDoc.getDrawingInfo()

    # Write date into the buffer object
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @model.vertexBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, drawingInfo.vertices, @gl.STATIC_DRAW)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @model.normalBuffer)
    @gl.bufferData(@gl.ARRAY_BUFFER, drawingInfo.normals, @gl.STATIC_DRAW)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, @model.colorBuffer);
    @gl.bufferData(@gl.ARRAY_BUFFER, drawingInfo.colors, @gl.STATIC_DRAW)

    # Write the indices to the buffer object
    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @model.indexBuffer)
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

class Part4Canvas extends Part3Canvas
  program_version: '5-4'
  phi: 45.0
  speed: 1.0

  constructor: (selector = 'part_4')->
    super(selector)

  setup: ->
    super()

    @lightAmbient = vec4(1.0, 1.0, 1.0, 1.0 )
    @lightDiffuse = vec4( 1.0, 1.0, 1.0, 1.0 )
    @lightSpecular = vec4( 1.0, 1.0, 1.0, 1.0 )

    @materialAmbient = vec4( 0.5, 0.5, 0.5, 1.0 )
    @materialDiffuse = vec4( 0.5, 0.5, 0.5, 1.0 )
    @materialSpecular = vec4( 0.5, 0.5, 0.5, 1.0 )
    @materialShininess = 100.0

    @setLightningProduct('ambientProduct', @lightAmbient, @materialAmbient)
    @setLightningProduct('diffuseProduct', @lightDiffuse, @materialDiffuse)
    @setLightningProduct('specularProduct', @lightSpecular, @materialSpecular)
    @gl.uniform1f(@gl.getUniformLocation(@program, "shininess"), @materialShininess)

    @setPerspective(10, 1.0, 0, 0.25)
    lightPosition = vec4(1.0, 1.0, 1.0, 0.0 )
    @gl.uniform4fv(@lightPosition, flatten(lightPosition))

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

  tick: ->
    @setModelViewMatrix(1, 45, @phi)
    @phi += @speed
    super()

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

window.onload = ->
  new Part3Canvas()
  new Part4Canvas()
