
#include <lauxlib.h>
#include <GL/glfw.h>
#include "luaglfw.h"


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




//************************************************************************
//****                    LUA Library Registration                    ****
//************************************************************************

// GLFW constants are stored in the global Lua table "gl"
static struct lua_constant gl_constants[] =
{
    // GL constants (GL_TRUE/GL_FALSE)
    { "TRUE", GL_TRUE },
    { "FALSE", GL_FALSE },
    
    { "DEPTH_TEST", GL_DEPTH_TEST },
    { "LESS", GL_LESS },
    { "COLOR_BUFFER_BIT", GL_COLOR_BUFFER_BIT },
    { "DEPTH_BUFFER_BIT", GL_DEPTH_BUFFER_BIT },

    { NULL, 0 }
};


// Library functions to register
static const luaL_Reg gllib[] = {

    { "Enable", gl_Enable },
    { "DepthFunc", gl_DepthFunc },

    { "ClearColor", gl_ClearColor },
    { "Clear", gl_Clear },

    { NULL, NULL }
};



int luaopen_gl( lua_State *L )
{
    // Store GLFW functions in "gl" table
    luaL_newlib( L, gllib );

    addConstants( L, gl_constants );
    
    lua_setglobal( L, "gl" );

    // Remember Lua state for callback functions
    callback_lua_state = L;

    return 0;
}