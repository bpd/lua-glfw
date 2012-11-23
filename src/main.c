/**
	
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <GL/glew.h>
#include <GL/glfw.h>


#ifdef _MSC_VER

typedef __int32 int32_t;
typedef unsigned __int32 uint32_t;
typedef __int64 int64_t;
typedef unsigned __int64 uint64_t;

#else
#include <stdint.h>
#endif

#include <math.h>


/*
void init( int width, int height, char* title )
{
  if( !glfwInit() )
  {
		fprintf( stderr, "Unable to init GLFW\n" );
	}

  // open an OpenGL 3.3 'core' context
	glfwOpenWindowHint( GLFW_FSAA_SAMPLES, 4 );
	glfwOpenWindowHint( GLFW_OPENGL_VERSION_MAJOR, 3 );
	glfwOpenWindowHint( GLFW_OPENGL_VERSION_MINOR, 3 );
  glfwOpenWindowHint( GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE );
	glfwOpenWindowHint( GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE );

	// open a window and creates OpenGL context
	if( !glfwOpenWindow( width, height, 0,0,0,0, 32,0, GLFW_WINDOW ) )
  {
			fprintf( stderr, "Failed to open GLFW window\n" );
      
			glfwTerminate();
			exit(1);
	}
  
  int major, minor, rev;
  glfwGetGLVersion( &major, &minor, &rev );
  printf( "OpenGL version: %d.%d.%d \n", major, minor, rev );
  
	// setup glew
  // 
  if( GLEW_OK != glewInit() )
  {
    // GLEW failed!
    fprintf( stderr, "Unable to init GLEW" );
    exit(1);
  }
	
	glfwSetWindowTitle( title );
  
  //fprintf( stdout, "version: %s", glGetString( GL_VERSION ) );
}



GLuint vertexArrayID;
GLuint vertexbuffer;

int object_vertex_count;

#define ATTRIB_VERTEX 0

void bind_object()
{
  
  //glmVec3f cross = glmCross( vec1, vec2 );
  
  // cross should be:   0.25, 0, -0.25
  
  //printf("cross: %f %f %f ", cross.x, cross.y, cross.z );

  GLfloat vertex_data[] = {
    0, 0,  0,
    -0.5f, 0.25f, -0.5f,
    0, 0,  0,
    0.5f, 0.25f, 0.5f,
    0,  0,  0,
    0,  0,  0  // reserved for cross(vec1, vec2)
  };
  
  glmCross3f( &vertex_data[3], &vertex_data[9], &vertex_data[15] );
  
  object_vertex_count = sizeof(vertex_data) / (3 * sizeof(float)); // 3 floats per vertex, 4 bytes each
  
  glGenVertexArrays( 1, &vertexArrayID );
	glBindVertexArray( vertexArrayID );
	
	glGenBuffers( 1, &vertexbuffer );
  glBindBuffer( GL_ARRAY_BUFFER, vertexbuffer );
	glBufferData( GL_ARRAY_BUFFER, sizeof(vertex_data), vertex_data, GL_STATIC_DRAW );
  glVertexAttribPointer(
    ATTRIB_VERTEX,				// attribute 0
    3,				// size
    GL_FLOAT,	// type
    GL_FALSE,	// normalized?
    0,				// stride, skip intensity
    (void*)0	// array buffer offset
  );

}

void render_object()
{
  glBindVertexArray( vertexArrayID );
	
  // enable the VAAs
  glEnableVertexAttribArray( ATTRIB_VERTEX );
  
  // draw the VBO
  glDrawArrays( GL_LINES, 0, object_vertex_count );
  
  // disable the VAAs
  glDisableVertexAttribArray( ATTRIB_VERTEX );
}




int main( int argc, char* argv[] )
{
  int running = GL_TRUE;
	double t = 0.0;
	
  printf("Initializing window\n");

  init( 1024, 768, "Test" );
  
  // setup buffers and shaders
	glClearColor( 0.0f, 0.0f, 0.3f, 0.0f );
	
  // bind VBOs
  bind_object();
	
	t = glfwGetTime();
	
	while( running )
	{
		double now = glfwGetTime();
    
    // if more than a second has passed, animate
    t = now;
    
    if( ( now - t  ) > (1.0f / 60.0f) )
    {
      continue;
		}

    // setup GL config
		glEnable( GL_DEPTH_TEST );
		glDepthFunc( GL_LESS );
		
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
    glColorMask( GL_TRUE, GL_FALSE, GL_FALSE, GL_TRUE );
    
    // draw VBOs
    render_object();
		
		// Swap front and back rendering buffers
		glfwSwapBuffers();
    
		// Check if ESC key was pressed or window was closed
		running = !glfwGetKey( GLFW_KEY_ESC )
							&& glfwGetWindowParam( GLFW_OPENED );
	}
  
  // clean up object data
  glDeleteBuffers( 1, &vertexbuffer );
  glDeleteVertexArrays( 1, &vertexArrayID );
	
	glfwTerminate();

	return 0;
}
*/

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include "luaglfw.h"

static int say_hello( lua_State *L )
{
  printf("Hello World\n");
  
  return 0; // return number of results
}

int main( int argc, char* argv[] )
{
  // Check arguments
  if( argc != 2 )
  {
     printf( "Usage: %s filename.lua\n", argv[0] );
     return -1;
  }
  
  lua_State *L = luaL_newstate();
  
  // open lua standard libraries
  luaL_openlibs(L);
  
  // open libraries
  luaopen_glfw( L );
  
  // 
  lua_pushcfunction(L, say_hello);
  lua_setglobal(L, "say_hello");
  
  // Load and run the selected Lua program
  if( luaL_dofile( L, argv[1] ) )
  {
     printf("Error running Lua program: %s\n", lua_tostring( L, -1 ) );
     lua_pop( L, 1 );
     return -1;
  }
  
  lua_close(L);
  
  return 0;
}
