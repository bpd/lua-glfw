--[[  Vector Functions  ]]--

Vector = { x=0, y=0, z=0 }

Vector._meta = {
  __add = function(u,v)
    if type(v) == "table" then
      return Vector{ u.x+v.x, u.y+v.y, u.z+v.z }
    elseif type(v) == "number" then
      return Vector{ u.x+v, u.y+v, u.z+v }
    end
  end,
  __sub = function(u,v)
    if type(v) == "table" then
      return Vector{ u.x-v.x, u.y-v.y, u.z-v.z }
    elseif type(v) == "number" then
      return Vector{ u.x-v, u.y-v, u.z-v }
    end
  end,
  __mul = function(u,v)
    if type(v) == "table" then
      return Vector{ u.x*v.x, u.y*v.y, u.z*v.z }
    elseif type(v) == "number" then
      return Vector{ u.x*v, u.y*v, u.z*v }
    end
  end,
   __div = function(u,v)
    assert(type(v) == "number", "Vectors can only be divided by scalars")
    return Vector{ u.x/v, u.y/v, u.z/v }
  end,
  __eq = function(u,v)
    assert( type(u) == "table" and type(v) == "table", 
            "Vectors can only be equal to other vectors" )
    return u.x==v.x and u.y==v.y and u.z==v.z
  end,
  __index = function(t, key)
    if key == "x" then
      return t[1]
    elseif key == "y" then
      return t[2]
    elseif key == "z" then
      return t[3]
    elseif key == "a" then
      return t[4]
    else
      return Vector[key]
    end
  end
}

setmetatable(Vector, {
  __call = function(self, o)
    o = o or {}
    setmetatable(o, Vector._meta)
    return o
  end
})

function Vector.dot(u, v)
  return (u.x * v.x) + (u.y * v.y) + (u.z * v.z)
end

assert( Vector{2,3,4}:dot( Vector{4,5,6} ) == 47, "Vector.dot" )

function Vector.cross(u, v)
  return Vector{
       (u.y * v.z) - (v.y * u.z),
		-( (u.x * v.z) - (v.x * u.z) ),
		   (u.x * v.y) - (v.x * u.y)
  }
end

assert( Vector{2,3,4}:cross(Vector{4,5,6}) == Vector{-2,4,-2}, "Vector.cross" )

function Vector.magnitude(u)
  return math.sqrt( u:dot(u) )
end

assert( Vector{2,3,4}:magnitude() == math.sqrt(29), "Vector.magnitude" )

function Vector.normalize(u)
	return u / u:magnitude()
end

assert( Vector{2,3,4}:normalize() == Vector{ 2/math.sqrt(29), 3/math.sqrt(29), 4/math.sqrt(29) }, "Vector.normalize" )

function Vector.print(u)
	print(u.x, u.y, u.z)
end

-- Vector tests
assert( Vector{1,2,3} + Vector{3,4,5} == Vector{4,6,8}, "Vector.__add" )
assert( Vector{1,2,3} + 3 == Vector{4,5,6}, "Vector.__add scalar" )
assert( Vector{1,2,3} * Vector{3,4,5} == Vector{3,8,15}, "Vector.__mul" )
assert( Vector{1,2,3} * 2 == Vector{2,4,6}, "Vector.__mul scalar" )


--[[  Matrix Functions  ]]--

Matrix = {}

Matrix._meta = {
  __mul = function(m1,m2)
  
    if type(m1) == "table" and type(m2) == "table" 
       and getmetatable(m1) == Matrix._meta then
    
      if getmetatable(m2) == Matrix._meta then
        return Matrix({
          (m1[1] * m2[1]) + (m1[2] * m2[5]) + (m1[3] * m2[9]) + (m1[4] * m2[13]),
          (m1[1] * m2[2]) + (m1[2] * m2[6]) + (m1[3] * m2[10]) + (m1[4] * m2[14]),
          (m1[1] * m2[3]) + (m1[2] * m2[7]) + (m1[3] * m2[11]) + (m1[4] * m2[15]),
          (m1[1] * m2[4]) + (m1[2] * m2[8]) + (m1[3] * m2[12]) + (m1[4] * m2[16]),

          (m1[5] * m2[1]) + (m1[6] * m2[5]) + (m1[7] * m2[9]) + (m1[8] * m2[13]),
          (m1[5] * m2[2]) + (m1[6] * m2[6]) + (m1[7] * m2[10]) + (m1[8] * m2[14]),
          (m1[5] * m2[3]) + (m1[6] * m2[7]) + (m1[7] * m2[11]) + (m1[8] * m2[15]),
          (m1[5] * m2[4]) + (m1[6] * m2[8]) + (m1[7] * m2[12]) + (m1[8] * m2[16]),

          (m1[9] * m2[1]) + (m1[10] * m2[5]) + (m1[11] * m2[9]) + (m1[12] * m2[13]),
          (m1[9] * m2[2]) + (m1[10] * m2[6]) + (m1[11] * m2[10]) + (m1[12] * m2[14]),
          (m1[9] * m2[3]) + (m1[10] * m2[7]) + (m1[11] * m2[11]) + (m1[12] * m2[15]),
          (m1[9] * m2[4]) + (m1[10] * m2[8]) + (m1[11] * m2[12]) + (m1[12] * m2[16]),

          (m1[13] * m2[1]) + (m1[14] * m2[5]) + (m1[15] * m2[9]) + (m1[16] * m2[13]),
          (m1[13] * m2[2]) + (m1[14] * m2[6]) + (m1[15] * m2[10]) + (m1[16] * m2[14]),
          (m1[13] * m2[3]) + (m1[14] * m2[7]) + (m1[15] * m2[11]) + (m1[16] * m2[15]),
          (m1[13] * m2[4]) + (m1[14] * m2[8]) + (m1[15] * m2[12]) + (m1[16] * m2[16])
        })
      elseif getmetatable(m2) == Vector._meta then
        local v = m2
        local m = m1
        local a = v.a or 1  -- expand the rvalue to a vec4 if necessary
        return Vector{
          (v.x*m[1]) + (v.y*m[5]) + (v.z*m[9])  + (a*m[13]),
          (v.x*m[2]) + (v.y*m[6]) + (v.z*m[10]) + (a*m[14]),
          (v.x*m[3]) + (v.y*m[7]) + (v.z*m[11]) + (a*m[15]),
          (v.x*m[4]) + (v.y*m[8]) + (v.z*m[12]) + (a*m[16])
        }
      end
    end
    assert( false, "Expected m1=Matrix, m2=Matrix|Vector" )
  end,
  __index = function(t, k)
    return Matrix[k]
  end
}

setmetatable(Matrix, {
  __call = function(self, o)
    o = o or Matrix.identity()
    setmetatable(o, Matrix._meta)
    return o
  end
})


function Matrix.identity()
  return Matrix({
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1 })
end

function Matrix.rotateX( radians )
  return Matrix({
    1, 0,                 0,                  0,
    0, math.cos(radians), -math.sin(radians), 0,
    0, math.sin(radians), math.cos(radians),  0,
    0, 0,                 0,                  1 })
end

function Matrix.rotateY( radians )
  return Matrix({
    math.cos(radians),  0,   math.sin(radians),  0,
    0,                  1,   0,                  0,
    -math.sin(radians), 0,   math.cos(radians),  0,
    0,                  0,   0,                  1 })
end

function Matrix.translate( x, y, z )
  return Matrix({
    1,	0,	0,	x,
		0,	1,	0,	y,
		0,	0,	1,	z,
		0,	0,	0,	1 })
end

function Matrix.scale( x, y, z )
  return Matrix({
    x,	0,	0,	0,
		0,	y,	0,	0,
		0,	0,	z,	0,
		0,	0,	0,	1 })
end

function Matrix.print( m )
  print( m[1], m[2], m[3], m[4] )
  print( m[5], m[6], m[7], m[8] )
  print( m[9], m[10], m[11], m[12] )
  print( m[13], m[14], m[15], m[16] )
end



--[[  OpenGL Helper Functions  ]]--
glu = glu or {}

function glu.LookAt( eye, center, up )
  local forward = (center - eye):normalize()

  local side = forward:cross(up):normalize()
  local up = side:cross(forward)
  
  local m = Matrix({
    side.x,	up.x,	-forward.x,	0,
		side.y,	up.y,	-forward.y,	0,
		side.z,	up.z,	-forward.z,	0,
		0,		  0,		0,		      1
  })
  
  return m * Matrix.translate( -eye.x, -eye.y, -eye.z )
end

glu.PI_OVER_360 = 3.14159265358979323846264338327950288 / 360

function glu.Perspective( fov, aspect, zNear, zFar )
  local h = 1 / math.tan( fov * glu.PI_OVER_360 )
  local neg_depth = zNear - zFar
  
  return Matrix({
    h/aspect,	0,	0,														0,
		0,				h,	0,														0,
		0,				0,	(zFar + zNear)/neg_depth,			(2*(zNear*zFar))/neg_depth,
		0,				0,	-1,                           0
  })
end


--[[  Begin Program  ]]--

glfw.Init()

print( glfw.GetVersion() )

--[[
for i,v in ipairs(glfw.GetVideoModes()) do
  for k,v in pairs(v) do
    print(k,v)
  end
end

for k,v in pairs(glfw.GetDesktopMode()) do print(k,v) end
--]]

glfw.OpenWindowHint( glfw.FSAA_SAMPLES, 4 );
glfw.OpenWindowHint( glfw.OPENGL_VERSION_MAJOR, 3 );
glfw.OpenWindowHint( glfw.OPENGL_VERSION_MINOR, 3 );
glfw.OpenWindowHint( glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE );
glfw.OpenWindowHint( glfw.OPENGL_FORWARD_COMPAT, glfw.GL_TRUE );

opened = glfw.OpenWindow( 1024, 768, 0, 0, 0, 0, 32, 0, glfw.WINDOW )
assert( not(opened == 0), "open window failed")

gl.GlewInit()

glfw.SetWindowTitle("Test");

glfw.SetWindowCloseCallback( function()
  print("window close requested")
  return 1 -- return 1 to close window, 0 to leave the window open
end )

glfw.SetWindowSizeCallback( function(w,h)
  print(w,h)
end )

glfw.SetWindowRefreshCallback( function()
  print("window refreshed")
end )

glfw.SetMouseButtonCallback( function(button,action)
  --print(button,action)
end )

glfw.SetMousePosCallback( function(x,y)
  --print(x,y)
end )

glfw.SetMouseWheelCallback( function(pos)
  --print(pos)
end )

glfw.SetKeyCallback( function(key,action)
  --print(key,action)
end )

glfw.SetCharCallback( function(key,action)
  --print(key,action)
end )

gl.ClearColor( 0, 0, 0.3, 0 )

vertices = gl.FloatArray.new( 12 )
assert( gl.FloatArray.size(vertices) == 12, "vertices.size" )
vertices[1] = 7
assert( vertices[1] == 7, "vertices[1]" )
--[[
vecs = {
  0,   0,     0,
 -0.5, 0.25, -0.5,
  0,   0,     0,
  0.5, 0.25,  0.5
}
]]--
vecs = {
  -- side
  -4,  2,   2,
  -4, -2,   2,
  -4, -2,  -2,
  
  -4,  2,   2,
  -4, -2,  -2,
  -4,  2,  -2,
  
  -- bottom
  -4,  -2,   2,
   2,  -2,   2,
  -4,  -2,  -2,
  
   2,  -2,   2,
  -4,  -2,  -2,
   2,  -2,  -2
}

-- bind VBO and VAA
vertexArrayID = gl.GenVertexArray()
gl.BindVertexArray( vertexArrayID )

vertexbufferID = gl.GenBuffer()
gl.BindBuffer( gl.ARRAY_BUFFER, vertexbufferID )
--gl.BufferData( gl.ARRAY_BUFFER, gl.FloatArray.size(vertices)*4, vertices, gl.STATIC_DRAW )
gl.BufferData( gl.ARRAY_BUFFER, #vecs, vecs, gl.STATIC_DRAW )
gl.VertexAttribPointer( 0, 3, gl.FLOAT, gl.FALSE, 0, 0 )

gl.BindBuffer( gl.ARRAY_BUFFER, 0 )
gl.BindVertexArray( vertexArrayID )


-- shader
programID = gl.LoadShader(
[[
  #version 330 core

  layout(location = 0) in vec3 vertex;
  
  uniform mat4 MVP;

  void main()
  {
    gl_Position = MVP * vec4(vertex,1);
  }
]],
[[
  #version 330 core

  // Ouput data
  out vec3 color;

  void main()
  {
    color = vec3( 0, 1, 0 ); // green
  }
]] )

print("programID: ", programID)

mvpID = gl.GetUniformLocation(programID, "MVP")
print("mvpID: ", mvpID)

eye = Vector{0,0,20}
center = Vector{0,0,0}
up = Vector{0,1,0}

model = Matrix()

view = glu.LookAt( eye, center, up )

projection = glu.Perspective( 45, 4/3, 0.1, 100 )

rotateAngle = 0

function rotateViewY( angle )
  local mRotation = Matrix.rotateY(-angle)
  local vDir = center - eye
  local vNewView = mRotation * vDir
  center = vNewView + eye
  
  view = glu.LookAt( eye, center, up )
end

function move( distance )
  local vDir = center - eye
  vDir = vDir * distance
  eye = eye + vDir
  center = center + vDir

  view = glu.LookAt( eye, center, up )
end

function processEvents()

  if glfw.GetKey( glfw.KEY_LEFT ) == glfw.PRESS then
    rotateViewY(-0.05)
  end
  if glfw.GetKey( glfw.KEY_RIGHT ) == glfw.PRESS then
    rotateViewY(0.05)
  end
  
  if glfw.GetKey( glfw.KEY_UP ) == glfw.PRESS then
    move( 0.05 )
  end
  if glfw.GetKey( glfw.KEY_DOWN ) == glfw.PRESS then
    move( -0.05 )
  end

end

function render()
  gl.Enable( gl.DEPTH_TEST )
  gl.DepthFunc( gl.LESS )
		
  gl.Clear( bit32.bor(gl.COLOR_BUFFER_BIT, gl.DEPTH_BUFFER_BIT) )
  
  --gl.ColorMask( true, false, false, true ) -- only allow red
  
  gl.UseProgram( programID )
  
  mvp = projection * view * model
  
  gl.UniformMatrix4f( mvpID, true, mvp )
  
  gl.BindVertexArray( vertexArrayID )
  gl.EnableVertexAttribArray( 0 )
  -- each vector has three components, so the element count is #vecs/3
  gl.DrawArrays( gl.TRIANGLES, 0, (#vecs)/3 )
  gl.DisableVertexAttribArray( 0 )
end


running = true
while running do

  processEvents()
  
  render()
  
  glfw.SwapBuffers()
  
  -- Check if ESC key was pressed or window was closed
  local esc_pressed = glfw.GetKey( glfw.KEY_ESC ) == glfw.PRESS
  if esc_pressed then
    print("escape pressed")
  end
  
  local opened = glfw.GetWindowParam( glfw.OPENED ) == glfw.TRUE
  if not opened then
    print("window no longer open")
  end
  
  running = opened and (not esc_pressed)
end

gl.DeleteVertexArray( vertexArrayID )
gl.DeleteBuffer( vertexbufferID )

gl.DeleteProgram( programID )

glfw.Terminate()
