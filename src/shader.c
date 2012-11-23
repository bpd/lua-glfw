#include <stdio.h>
#include <stdlib.h>
#include <GL/glew.h>
#include "shader.h"

const char* file_contents( const char* filename )
{
  // read the file contents
  char* contents;
  int size = 0;
  int bytesRead = 0;
  
  FILE *f = fopen( filename, "rb" );
  if( f == NULL )
  {
    return NULL;
  }
  
  // figure out how large the file is by seeking to
  // the end and seeing what offset we're at
  fseek( f, 0, SEEK_END );
  size = ftell( f );
  
  // see back to the beginning of the file
  fseek( f, 0, SEEK_SET );
  
  // allocate enough space to read the shader
  contents = (char*)malloc( size + 1 );
  
  // read the shader data, then close the file
  bytesRead = fread( contents, sizeof(char), size, f );
  fclose( f );
  
  if( size != bytesRead )
  {
    // read failed, free the allocated buffer and return
    free( contents );
    return NULL;
  }
  
  // null-terminate the string
  contents[size] = 0;
  return contents;
}

GLuint create_shader( GLenum eShaderType, const char* shaderData )
{
  GLint status;
  GLuint shader = glCreateShader(eShaderType);
  
  //fprintf( stdout, "Loading shader:\n %s\n", shaderData );
  
  glShaderSource( shader, 1, (const GLchar **)&shaderData, NULL );
  
  glCompileShader( shader );
  
  // verify compilation
  glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
  if (status == GL_FALSE)
  {
      GLint infoLogLength;
      glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLogLength);
      
      GLchar strInfoLog[infoLogLength + 1];
      glGetShaderInfoLog(shader, infoLogLength, NULL, strInfoLog);
      
      const char *strShaderType = NULL;
      switch(eShaderType)
      {
      case GL_VERTEX_SHADER: strShaderType = "vertex"; break;
      case GL_GEOMETRY_SHADER: strShaderType = "geometry"; break;
      case GL_FRAGMENT_SHADER: strShaderType = "fragment"; break;
      }
      
      fprintf(  stderr, 
                "Compile failure in %s shader:\n%s\n", 
                strShaderType, 
                strInfoLog);
  }

	return shader;
}

GLuint load_shader( const char* vertexData, const char* fragmentData )
{
	GLuint vertexShader = create_shader( GL_VERTEX_SHADER, vertexData );
	GLuint fragmentShader = create_shader( GL_FRAGMENT_SHADER, fragmentData );
	
	// create program
  GLuint programID = glCreateProgram();
  
  glAttachShader( programID, vertexShader );
  glAttachShader( programID, fragmentShader );
  
  glLinkProgram( programID );
  
  GLint status;
  glGetProgramiv( programID, GL_LINK_STATUS, &status );
  if( status == GL_FALSE )
  {
    GLint infoLogLength;
    glGetProgramiv( programID, GL_INFO_LOG_LENGTH, &infoLogLength );
    
    GLchar strInfoLog[ infoLogLength + 1 ];
    glGetProgramInfoLog( programID, infoLogLength, NULL, strInfoLog );
    fprintf( stderr, "Linker failure: %s\n", strInfoLog );
  }
  
  glDetachShader( programID, vertexShader );
  glDetachShader( programID, fragmentShader );
  
  return programID;
}

/**
 * returns program ID
 */
GLuint load_shader_files( const char* vertexFile, const char* fragmentFile )
{
  // create shaders
	const char* vertexShaderSource = file_contents( vertexFile );
	const char* fragmentShaderSource = file_contents( fragmentFile );
  
	GLuint programID = 0;
	
	if( vertexShaderSource != NULL && fragmentShaderSource != NULL )
	{
		programID = load_shader( vertexShaderSource, fragmentShaderSource );
  }
	
	if( vertexShaderSource != NULL )
	{
		free( (char*) vertexShaderSource );
	}
	
	if( fragmentShaderSource != NULL )
	{
		free( (char*) fragmentShaderSource );
	}
	
  return programID;
}