

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

  void main()
  {
    gl_Position = vec4(vertex,1);
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


running = true
while running do

  gl.Enable( gl.DEPTH_TEST )
  gl.DepthFunc( gl.LESS )
		
  gl.Clear( bit32.bor(gl.COLOR_BUFFER_BIT, gl.DEPTH_BUFFER_BIT) )
  
  --gl.ColorMask( true, false, false, true ) -- only allow red
  
  gl.UseProgram( programID )
  
  gl.BindVertexArray( vertexArrayID )
  gl.EnableVertexAttribArray( 0 )
  -- each vector has three components, so the element count is #vecs/3
  gl.DrawArrays( gl.LINES, 0, (#vecs)/3 )
  gl.DisableVertexAttribArray( 0 )
  
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
