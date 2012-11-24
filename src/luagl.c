
#include <math.h>

#include <lauxlib.h>
#include <GL/glew.h>
#include "luagl.h"

#include "shader.h"


struct lua_constant
{
    char *str;
    int  value;
};

// Add constants to the table on top of the stack
static void addConstants( lua_State *L, struct lua_constant *cn )
{
    while( cn->str )
    {
        lua_pushstring( L, cn->str );
        lua_pushnumber( L, cn->value );
        lua_rawset( L, -3 );
        ++ cn;
    }
}


static void stackDump (lua_State *L) {
  int i;
  int top = lua_gettop(L);
  for (i = 1; i <= top; i++)
  {
    int t = lua_type(L, i);
    printf("[%d] ", i);
    switch (t) {

      case LUA_TSTRING:  /* strings */
        printf("`%s'", lua_tostring(L, i));
        break;

      case LUA_TBOOLEAN:  /* booleans */
        printf(lua_toboolean(L, i) ? "true" : "false");
        break;

      case LUA_TNUMBER:  /* numbers */
        printf("%g", lua_tonumber(L, i));
        break;

      default:  /* other values */
        printf("%s", lua_typename(L, t));
        break;

    }
    printf("  \n");  /* put a separator */
  }
  printf("\n");  /* end the listing */
}

//************************************************************************
//****                 GLEW Proxy Functions                           ****
//************************************************************************

static int glew_Init(lua_State *L)
{
  if( GLEW_OK != glewInit() )
  {
    lua_settop( L, 0 );
    lua_pushstring( L, "Unable to initialize GLEW" );
    lua_error( L );
  }
  return 0;
}


//************************************************************************
//****                 Array userdata Functions                       ****
//************************************************************************

typedef struct FloatArray
{
  int size;
  float values[1]; /* variable */
}
FloatArray;

static int newarray( lua_State *L )
{
  int n = luaL_checkint(L, 1);
  size_t nbytes = sizeof(FloatArray) + (n-1)*sizeof(float);
  FloatArray *a = (FloatArray *)lua_newuserdata(L, nbytes);
  
  // TODO use a ref here
  luaL_getmetatable(L, "FloatArray.meta");
  lua_setmetatable(L, -2);
  
  a->size = n;
  return 1; /* new userdatum is already on the stack */
}

static int getarray( lua_State *L )
{
  FloatArray *a = (FloatArray *)lua_touserdata(L, 1);
  int index = luaL_checkint(L, 2);
  
  luaL_argcheck(L, a != NULL, 1, "`array` expected");
  
  luaL_argcheck(L, 1 <= index && index <= a->size, 2, "index out of range");
  
  lua_pushnumber(L, a->values[index-1]);
  return 1;
}

static int setarray( lua_State *L )
{
  FloatArray *a = (FloatArray *)lua_touserdata(L, 1);
  int index = luaL_checkint(L, 2);
  lua_Number value = luaL_checknumber(L, 3);
  
  luaL_argcheck(L, a != NULL, 1, "`array` expected");
  
  luaL_argcheck(L, 1 <= index && index <= a->size, 2, "index out of range");
  
  a->values[index-1] = value;
  return 0;
}

static int getsize( lua_State *L )
{
  FloatArray *a = (FloatArray*) lua_touserdata(L, 1);
  luaL_argcheck(L, a != NULL, 1, "`array` expected");
  lua_pushnumber(L, a->size);
  return 1;
}

static const struct luaL_Reg floatarraylib [] = {
  {"new", newarray},
  {"set", setarray},
  {"get", getarray},
  {"size", getsize},
  {NULL, NULL}
};


//************************************************************************
//****                    GL Proxy Functions                          ****
//************************************************************************

static lua_State * callback_lua_state = (lua_State *) 0;

static int gl_Enable(lua_State *L)
{
  glEnable(luaL_checknumber(L, 1));
  return 0;
}

static int gl_DepthFunc(lua_State *L)
{
  glDepthFunc(luaL_checknumber(L, 1));
  return 0;
}

/*Clear (mask) -> none*/
static int gl_Clear(lua_State *L)
{
  glClear(luaL_checknumber(L, 1));
  return 0;
}

/*ClearColor (red, green, blue, alpha) -> none*/
static int gl_ClearColor(lua_State *L)
{
  glClearColor((GLclampf)luaL_checknumber(L, 1), (GLclampf)luaL_checknumber(L, 2),
               (GLclampf)luaL_checknumber(L, 3), (GLclampf)luaL_checknumber(L, 4));
  return 0;
}

/*GenVertexArray () -> arrayID*/
static int gl_GenVertexArray(lua_State *L)
{
  GLuint arrayID;
  glGenVertexArrays(1, &arrayID);
  lua_pushnumber(L, arrayID);
  return 1;
}

/*DeleteVertexArray (arrayID) -> none*/
static int gl_DeleteVertexArray(lua_State *L)
{
  GLuint arrayID = luaL_checkint(L,1);
  glDeleteBuffers(1, &arrayID);
  return 0;
}

/*BindVertexArray (arrayID) -> none*/
static int gl_BindVertexArray(lua_State *L)
{
  glBindVertexArray( luaL_checkint(L,1) );
  return 0;
}

/*GenBuffer () -> bufferID*/
static int gl_GenBuffer(lua_State *L)
{
  GLuint bufferID;
  glGenBuffers(1, &bufferID);
  lua_pushnumber(L, bufferID);
  return 1;
}

/*DeleteBuffer (bufferID) -> none*/
static int gl_DeleteBuffer(lua_State *L)
{
  GLuint bufferID = luaL_checkint(L, 1);
  glDeleteBuffers(1, &bufferID);
  return 0;
}

/*BindBuffer (type, bufferID) -> none*/
static int gl_BindBuffer(lua_State *L)
{
  glBindBuffer( luaL_checkint(L, 1), luaL_checkint(L, 2) );
  return 0;
}

static void table2array( lua_State *L, int stack_index, float* dst, int size )
{
  int i;
  for( i=1; i<=size; i++ )
  {
    lua_rawgeti(L, stack_index, i);
    dst[i-1] = lua_tonumber(L, -1);
    lua_pop(L, 1);
  }
}

/*BufferData (type, len, data, op) -> none*/
static int gl_BufferData(lua_State *L)
{
  int size = luaL_checkint(L, 2);
  
  int type = lua_type(L, 3);
  if( type == LUA_TUSERDATA )
  {
    // use a FloatArray as the buffer data input
    FloatArray *data = (FloatArray*) lua_touserdata(L, 3);
    
    glBufferData( luaL_checkint(L, 1), size,
                  data->values, luaL_checkint(L, 4) );
  }
  else if( type == LUA_TTABLE )
  {
    // use a lua table as the buffer data input
    
    // read the table (as an array) values by index
    float values[size];
    
    table2array( L, 3, values, size );
    
    glBufferData( luaL_checkint(L, 1), size*sizeof(lua_Number),
                  values, luaL_checkint(L, 4) );
  }
  else
  {
    lua_settop( L, 0 );
    lua_pushstring( L, "Unknown buffer data type" );
    lua_error( L );
  }
  return 0;
}

/*VertexAttribPointer (attrib_id, size, type, normalized, stride, buffer_offset) 
  -> none*/
static int gl_VertexAttribPointer(lua_State *L)
{
  glVertexAttribPointer(luaL_checkint(L, 1), luaL_checkint(L, 2),
                        luaL_checkint(L, 3), luaL_checkint(L, 4),
                        luaL_checkint(L, 5), (GLvoid*)lua_topointer(L, 6) );
  return 0;
}

/*EnableVertexAttribArray (attribArrayID) -> none*/
static int gl_EnableVertexAttribArray(lua_State *L)
{
  glEnableVertexAttribArray( luaL_checkint(L, 1) );
  return 0;
}

/*DrawArrays (type, offset, size) -> none*/
static int gl_DrawArrays(lua_State *L)
{
  glDrawArrays( luaL_checkint(L, 1), luaL_checkint(L, 2), luaL_checkint(L, 3) );
  return 0;
}

/*DisableVertexAttribArray (attribArrayID) -> none*/
static int gl_DisableVertexAttribArray(lua_State *L)
{
  glDisableVertexAttribArray( luaL_checkint(L, 1) );
  return 0;
}

/*ColorMask (red, green, blue, alpha) -> none*/
static int gl_ColorMask(lua_State *L)
{
  glColorMask( lua_toboolean(L, 1), lua_toboolean(L, 2),
               lua_toboolean(L, 3), lua_toboolean(L, 4) );
  return 0;
}

/*UseProgram (programID) -> none*/
static int gl_UseProgram(lua_State *L)
{
  glUseProgram( luaL_checkint(L, 1) );
  return 0;
}

/*DeleteProgram (programID) -> none*/
static int gl_DeleteProgram(lua_State *L)
{
  glDeleteProgram( luaL_checkint(L, 1) );
  return 0;
}

/*UniformMatrix4f (locationID, transpose, value) -> none*/
static int gl_UniformMatrix4f(lua_State *L)
{
  luaL_checktype(L, 3, LUA_TTABLE);
  
  float values[16]; // 4x4 matrix
  
  table2array(L, 3, values, 16);
  
  glUniformMatrix4fv( luaL_checkint(L, 1), 1, lua_toboolean(L, 2), values );
  
  return 0;
}

/* GetUniformLocation( programID, name ) -> locationID */
static int gl_GetUniformLocation(lua_State *L)
{
  int locID = glGetUniformLocation( luaL_checkint(L,1), luaL_checkstring(L,2) );
  lua_pushnumber(L, locID);
  return 1;
}


//************************************************************************
//****                    Helper Functions                            ****
//************************************************************************

/*LoadShader (vertex_content, fragment_content) -> programID*/
static int gl_LoadShader(lua_State *L)
{
  int programID = load_shader( luaL_checkstring(L, 1), luaL_checkstring(L, 2) );
  lua_pushnumber(L, programID);
  return 1;
}


//************************************************************************
//****                    LUA Library Registration                    ****
//************************************************************************

// GLFW constants are stored in the global Lua table "gl"
static struct lua_constant gl_constants[] =
{
    // GLEW constants
    { "GLEW_OK", GLEW_OK },
    
    // GL constants (GL_TRUE/GL_FALSE)
    { "TRUE", GL_TRUE },
    { "FALSE", GL_FALSE },
    
    // GL types
    { "FLOAT", GL_FLOAT },
    
    // draw constants
    { "DEPTH_TEST", GL_DEPTH_TEST },
    { "LESS", GL_LESS },
    { "COLOR_BUFFER_BIT", GL_COLOR_BUFFER_BIT },
    { "DEPTH_BUFFER_BIT", GL_DEPTH_BUFFER_BIT },
    
    { "POINTS", GL_POINTS },
    { "LINE_STRIP", GL_LINE_STRIP },
    { "LINE_LOOP", GL_LINE_LOOP },
    { "LINES", GL_LINES },
    { "LINE_STRIP_ADJACENCY", GL_LINE_STRIP_ADJACENCY },
    { "LINES_ADJACENCY", GL_LINES_ADJACENCY },
    { "TRIANGLE_STRIP", GL_TRIANGLE_STRIP },
    { "TRIANGLE_FAN", GL_TRIANGLE_FAN },
    { "TRIANGLES", GL_TRIANGLES },
    { "TRIANGLE_STRIP_ADJACENCY", GL_TRIANGLE_STRIP_ADJACENCY },
    { "TRIANGLES_ADJACENCY", GL_TRIANGLES_ADJACENCY },
    { "PATCHES", GL_PATCHES },
    
    
    // VBO constants
    { "ARRAY_BUFFER", GL_ARRAY_BUFFER },
    { "STATIC_DRAW", GL_STATIC_DRAW },

    { NULL, 0 }
};


// Library functions to register
static const luaL_Reg gllib[] = {

    // GLEW
    { "GlewInit", glew_Init },

    // OpenGL 3.3

    { "Enable", gl_Enable },
    { "DepthFunc", gl_DepthFunc },

    { "ClearColor", gl_ClearColor },
    { "Clear", gl_Clear },
    { "ColorMask", gl_ColorMask },
    
    // VA, VBO management
    { "GenVertexArray", gl_GenVertexArray },
    { "DeleteVertexArray", gl_DeleteVertexArray },
    { "BindVertexArray", gl_BindVertexArray },
    
    { "GenBuffer", gl_GenBuffer },
    { "DeleteBuffer", gl_DeleteBuffer },
    { "BindBuffer", gl_BindBuffer },
    { "BufferData", gl_BufferData },
    { "VertexAttribPointer", gl_VertexAttribPointer },
    { "EnableVertexAttribArray", gl_EnableVertexAttribArray },
    { "DrawArrays", gl_DrawArrays },
    { "DisableVertexAttribArray", gl_DisableVertexAttribArray },
    
    // shader
    { "UseProgram", gl_UseProgram },
    { "DeleteProgram", gl_DeleteProgram },
    { "UniformMatrix4f", gl_UniformMatrix4f },
    { "GetUniformLocation", gl_GetUniformLocation },
    
    // helper functions
    { "LoadShader", gl_LoadShader },

    { NULL, NULL }
};



int luaopen_gl( lua_State *L )
{
    // Store GLFW functions in "gl" table
    luaL_newlib( L, gllib );

    addConstants( L, gl_constants );
    
    // Store FloatArray functions in "gl.FloatArray" table
    lua_pushstring( L, "FloatArray" );
    luaL_newlib( L, floatarraylib );
    lua_rawset( L, -3 );
    
    // set metable for t[index], t[index]=x  assignment
    luaL_newmetatable(L, "FloatArray.meta");
    
    lua_pushstring(L, "__index");
    lua_pushcfunction(L, getarray);
    lua_rawset(L, -3);
    
    lua_pushstring(L, "__newindex");
    lua_pushcfunction(L, setarray);
    lua_rawset(L, -3);
    
    lua_pop(L, 1); // remove metatable pushed on stack by creation
    
    // the 'gl' table will still be on the stack, use it to set its global name
    lua_setglobal( L, "gl" );

    // Remember Lua state for callback functions
    callback_lua_state = L;

    return 0;
}