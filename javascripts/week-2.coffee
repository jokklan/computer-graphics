---
---
class Canvas
  constructor: (selector)->
    # Part 1
    @container = document.getElementById(selector)
    @gl = @setupCanvas(selector)
    @canvas = @gl.canvas
    @index = 0
    @maxPoints = 2
    @pointPositions = []
    @setBackground()
    @render()

  getPosition: (event)->
    pos = event.target.getBoundingClientRect()
    canvasX = pos.left
    canvasY = pos.top
    x = - 1 + 2 * ((event.clientX - canvasX) / @canvas.width)
    y = - 1 + 2 * ((@canvas.height - (event.clientY - canvasY)) / @canvas.height)
    vec2(x, y)

  setPosition: (position)->
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @vBuffer)
    @gl.bufferSubData(@gl.ARRAY_BUFFER, sizeof['vec2'] * @index, flatten(position))
    @pointPositions.push(position)

  increaseBufferSize: (buffer, attribute, dimensions, size, attributes) ->
    buffer = @createBuffer(size * @maxPoints)
    for attr, index in attributes
      @gl.bufferSubData(@gl.ARRAY_BUFFER, size * index, flatten(attr))

    @writeData(attribute, dimensions)
    buffer

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

  checkBufferSize: ->
    if @index >= @maxPoints
      @updateBufferSize()

  updateBufferSize: ->
    @maxPoints = @maxPoints * 2

  render: () ->
    @gl.clear(@gl.COLOR_BUFFER_BIT)
    @gl.drawArrays(@gl.POINTS, 0, @index)

class Part1Canvas extends Canvas
  program_version: '2-1'
  constructor: (selector = 'part_1')->
    super(selector)
    @program = @loadShaders()
    @vBuffer = @createBuffer(sizeof['vec2'] * @maxPoints)
    @writeData('vPosition', 2)
    @setupClickEvent()

  updateBufferSize: ->
    super()
    @vBuffer = @increaseBufferSize(@vBuffer, 'vPosition', 2, sizeof['vec2'], @pointPositions)

  setupClickEvent: ->
    @canvas.addEventListener 'click', (event)=>
      @checkBufferSize()
      @setPosition(@getPosition(event))
      @index++
      @render()

class Part2Canvas extends Part1Canvas
  program_version: '2-2'
  constructor: (selector = 'part_2')->
    super(selector)
    @colorIndex = 0
    @pointColors = []
    @colors = [
      vec4(0.0, 0.0, 0.0, 1.0), # black
      vec4(1.0, 0.0, 0.0, 1.0), # red
      vec4(1.0, 1.0, 0.0, 1.0), # yellow
      vec4(0.0, 1.0, 0.0, 1.0), # green
      vec4(0.0, 0.0, 1.0, 1.0), # blue
      vec4(1.0, 0.0, 1.0, 1.0), # magenta
      vec4(0.0, 1.0, 1.0, 1.0)  # cyan
    ]

    @program = @loadShaders()
    @cBuffer = @createBuffer(sizeof['vec4'] * @maxPoints)
    @writeData('vColor', 4)

    @setupClearButton()
    @setupColorSelect()

  updateBufferSize: ->
    super()
    @cBuffer = @increaseBufferSize(@cBuffer, 'vColor', 4, sizeof['vec4'], @pointColors)

  setupClickEvent: ->
    @canvas.addEventListener 'click', (event)=>
      @checkBufferSize()

      @setPosition(@getPosition(event))
      @setColor(@getColor())

      @index++
      @render()

  setupColorSelect: ->
    selectMenu = @container.getElementsByClassName("color_select")[0]
    selectMenu.addEventListener 'change', (event)=>
      @colorIndex = selectMenu.options[selectMenu.selectedIndex].value

  setupClearButton: ->
    button = @container.getElementsByClassName('clear_button')[0]
    button.addEventListener 'click', =>
      @reset()

  getColor: ->
    @colors[@colorIndex]

  setColor: (color)->
    @gl.bindBuffer(@gl.ARRAY_BUFFER, @cBuffer)
    @gl.bufferSubData(@gl.ARRAY_BUFFER, sizeof['vec4'] * @index, flatten(color))
    @pointColors.push(color)

  reset: ->
    @index = 0
    @pointPositions = []
    @colorPositions = []
    @setBackground()
    @render()

class Part3Canvas extends Part2Canvas
  constructor: (selector = 'part_3')->
    @pointIndices = []
    @triangleIndices = []
    super(selector)
    @mode = 'points'
    @triangleIndex = 0
    @setupModeButton('points_button')
    @setupModeButton('triangles_button')

  setupClickEvent: ->
    @canvas.addEventListener 'click', (event)=>
      @checkBufferSize()

      @setPosition(@getPosition(event))
      @setColor(@getColor())

      switch @mode
        when 'points'
          @pointIndices.push(@index)
        when 'triangles'
          if @triangleIndex < 2
            @pointIndices.push(@index)
            @triangleIndex++
          else
            @triangleIndex = 0
            @pointIndices.pop()
            @pointIndices.pop()
            @triangleIndices.push(@index - 2)

      @index++
      @render()

  setupModeButton: (selector)->
    button = @container.getElementsByClassName(selector)[0]
    button.addEventListener 'click', (event)=>
      @setMode(event.target.value)

  setMode: (mode)->
    @mode = mode
    @triangleIndex = 0 if mode == 'triangles'

  render: () ->
    @gl.clear(@gl.COLOR_BUFFER_BIT)

    for i in @pointIndices
      @gl.drawArrays(@gl.POINTS, i, 1)

    for i in @triangleIndices
      @gl.drawArrays(@gl.TRIANGLE_STRIP, i, 3)

class Part4Canvas extends Part3Canvas
  constructor: (selector = 'part_4')->
    @sphereIndices = []
    super(selector)
    @sphereIndex = 0
    @setupModeButton('spheres_button')

  setupClickEvent: ->
    @canvas.addEventListener 'click', (event)=>
      @checkBufferSize()

      if @mode == 'spheres' && @sphereIndex >= 1
        @sphereIndex = 0
        @pointIndices.pop()
        @sphereIndices.push(@index - 1)

        point = @getPosition(event)
        center = @pointPositions[@pointPositions.length - 1]
        @drawCircle(center, point)

        @render()

      else
        @setPosition(@getPosition(event))
        @setColor(@getColor())

        switch @mode
          when 'points'
            @pointIndices.push(@index)
          when 'triangles'
            if @triangleIndex < 2
              @pointIndices.push(@index)
              @triangleIndex++
            else
              @triangleIndex = 0
              @pointIndices.pop()
              @pointIndices.pop()
              @triangleIndices.push(@index - 2)
          when 'spheres'
            @pointIndices.push(@index)
            @sphereIndex++

        @index++
        @render()


  drawCircle: (center, lastPoint)->
    length = Math.abs(center[0] - lastPoint[0])
    height = Math.abs(center[1] - lastPoint[1])

    radius = Math.sqrt(Math.pow(length, 2) + Math.pow(height, 2))
    step = 0.1

    for i in [0..2*Math.PI + step] by step
      if @index >= @maxPoints
        @maxPoints = @maxPoints * 2
        @vBuffer = @increaseBufferSize(@vBuffer, 'vPosition', 2, sizeof['vec2'], @pointPositions)
        @cBuffer = @increaseBufferSize(@cBuffer, 'vColor', 4, sizeof['vec4'], @pointColors)

      position = [Math.cos(i) * radius + center[0], Math.sin(i) * radius + center[1]]
      @setPosition(position)
      @setColor(@getColor())
      @index++


  setMode: (mode)->
    super(mode)
    @sphereIndex = 0 if mode == 'spheres'

  render: () ->
    super()

    console.log @sphereIndices
    for i in @sphereIndices
      @gl.drawArrays(@gl.TRIANGLE_FAN, i, 65)


window.onload = ->
  new Part1Canvas()
  new Part2Canvas()
  new Part3Canvas()
  new Part4Canvas()




