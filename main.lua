
function glmIdentity()
  return {
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1 }
end

function glmRotateX( degree )
  return {
    1, 0,                0,                 0,
    0, math.cos(degree), -math.sin(degree), 0,
    0, math.sin(degree), math.cos(degree),  0,
    0, 0,                0,                 1 }
end

function glmRotateY( degree )
  return {
		math.cos(degree),  0,   math.sin(degree),  0,
    0,                 1,   0,                 0,
    -math.sin(degree), 0,   math.cos(degree),  0,
    0,                 0,   0,                 1 }
end
    

function glmMulMatrix( m1, m2 )
  dst = {}
  dst[1] = (m1[1] * m2[1]) + (m1[2] * m2[5]) + (m1[3] * m2[9]) + (m1[4] * m2[13])
	dst[2] = (m1[1] * m2[2]) + (m1[2] * m2[6]) + (m1[3] * m2[10]) + (m1[4] * m2[14])
	dst[3] = (m1[1] * m2[3]) + (m1[2] * m2[7]) + (m1[3] * m2[11]) + (m1[4] * m2[15])
	dst[4] = (m1[1] * m2[4]) + (m1[2] * m2[8]) + (m1[3] * m2[12]) + (m1[4] * m2[16])
	
	dst[5] = (m1[5] * m2[1]) + (m1[6] * m2[5]) + (m1[7] * m2[9]) + (m1[8] * m2[13])
	dst[6] = (m1[5] * m2[2]) + (m1[6] * m2[6]) + (m1[7] * m2[10]) + (m1[8] * m2[14])
	dst[7] = (m1[5] * m2[3]) + (m1[6] * m2[7]) + (m1[7] * m2[11]) + (m1[8] * m2[15])
	dst[8] = (m1[5] * m2[4]) + (m1[6] * m2[8]) + (m1[7] * m2[12]) + (m1[8] * m2[16])
	
	dst[9] = (m1[9] * m2[1]) + (m1[10] * m2[5]) + (m1[11] * m2[9]) + (m1[12] * m2[13])
	dst[10] = (m1[9] * m2[2]) + (m1[10] * m2[6]) + (m1[11] * m2[10]) + (m1[12] * m2[14])
	dst[11] = (m1[9] * m2[3]) + (m1[10] * m2[7]) + (m1[11] * m2[11]) + (m1[12] * m2[15])
	dst[12] = (m1[9] * m2[4]) + (m1[10] * m2[8]) + (m1[11] * m2[12]) + (m1[12] * m2[16])
	
	dst[13] = (m1[13] * m2[1]) + (m1[14] * m2[5]) + (m1[15] * m2[9]) + (m1[16] * m2[13])
	dst[14] = (m1[13] * m2[2]) + (m1[14] * m2[6]) + (m1[15] * m2[10]) + (m1[16] * m2[14])
	dst[15] = (m1[13] * m2[3]) + (m1[14] * m2[7]) + (m1[15] * m2[11]) + (m1[16] * m2[15])
	dst[16] = (m1[13] * m2[4]) + (m1[14] * m2[8]) + (m1[15] * m2[12]) + (m1[16] * m2[16])

  return dst
end



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
  print(button,action)
end )

glfw.SetMousePosCallback( function(x,y)
  print(x,y)
end )

glfw.SetMouseWheelCallback( function(pos)
  print(pos)
end )

glfw.SetKeyCallback( function(key,action)
  print(key,action)
end )

glfw.SetCharCallback( function(key,action)
  print(key,action)
end )

gl.ClearColor( 0, 0, 0.3, 0 )

vertices = gl.FloatArray.new( 12 )
assert( gl.FloatArray.size(vertices) == 12, "vertices.size" )
vertices[1] = 7
assert( vertices[1] == 7, "vertices[1]" )

vecs = {
  0,   0,     0,
 -0.5, 0.25, -0.5,
  0,   0,     0,
  0.5, 0.25,  0.5
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

mvp = glmIdentity()


function processEvents()

  if glfw.GetKey( glfw.KEY_LEFT ) == glfw.PRESS then
    mvp = glmMulMatrix( mvp, glmRotateY( -0.05 ) )
  elseif glfw.GetKey( glfw.KEY_RIGHT ) == glfw.PRESS then
    mvp = glmMulMatrix( mvp, glmRotateY( 0.05 ) )
  end
  
  if glfw.GetKey( glfw.KEY_UP ) == glfw.PRESS then
    mvp = glmMulMatrix( mvp, glmRotateX( -0.05 ) )
  elseif glfw.GetKey( glfw.KEY_DOWN ) == glfw.PRESS then
    mvp = glmMulMatrix( mvp, glmRotateX( 0.05 ) )
  end

end

function render()
  gl.Enable( gl.DEPTH_TEST )
  gl.DepthFunc( gl.LESS )
		
  gl.Clear( bit32.bor(gl.COLOR_BUFFER_BIT, gl.DEPTH_BUFFER_BIT) )
  
  --gl.ColorMask( true, false, false, true ) -- only allow red
  
  gl.UseProgram( programID )
  
  gl.UniformMatrix4f( mvpID, false, mvp )
  
  gl.BindVertexArray( vertexArrayID )
  gl.EnableVertexAttribArray( 0 )
  -- each vector has three components, so the element count is #vecs/3
  gl.DrawArrays( gl.LINES, 0, (#vecs)/3 )
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
