
i = glfw.Init()
if init == 0 then
  print("init failed")
end

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

if opened == 0 then
  print("open window failed")
end

gl.ClearColor( 0, 0, 0.3, 0 )

running = true
while running do

  gl.Enable( gl.DEPTH_TEST )
  gl.DepthFunc( gl.LESS )
		
  gl.Clear( bit32.bor(gl.COLOR_BUFFER_BIT, gl.DEPTH_BUFFER_BIT) )
  
  
  -- Check if ESC key was pressed or window was closed
  local esc_pressed = glfw.GetKey( glfw.KEY_ESC ) == glfw.PRESS
  if esc_pressed then
    print("escape pressed")
  end
  
  local opened = glfw.GetWindowParam( glfw.OPENED ) == glfw.TRUE
  if not opened then
    print("window no longer open")
  end
  
  glfw.SwapBuffers()
  
  running = opened and (not esc_pressed)

end

glfw.Terminate()
