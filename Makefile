CC = gcc

DEADCODESTRIP =  \
								-fdata-sections \
								-ffunction-sections \
								-Wl,--gc-sections \
								-Wl,--strip-all

# -Wl,-static
# Link against static libraries.  Required for dead-code elimination

# -fdata-sections
# -ffunction-sections
# Keep data/functions in separate sections, so they can be discarded if unused

# Wl,--gc-sections
# tell the linker to garbage collect sections

# -s
# strip debug information
								
CFLAGS = -O3 -m64 -Wall -std=c99 -pedantic \
         -DGLEW_STATIC -DGLEW_NO_GLU \
         -DGLFW_NO_GLU 

LIBS = ./lib/liblua.a

INCLUDES = -I./include -I./external/lua-5.2.1/src

default: 
	echo "make win64 | x11"

win64: LFLAGS = -L./lib/win64 
win64: LIBS += -lglfw -lglu32 -lopengl32
win64: CFLAGS += -Wl,-static 
win64: EXEC_EXT = exe
win64: executables

win64-clean: clean-objs
	rm -f a.exe

x11: LFLAGS = -L./lib/x11  -L/usr/lib
x11: LIBS += ./lib/x11/libglfw.a -lGLU -lGL
x11: EXEC_EXT = out
x11: executables

x11-clean: clean-objs
	rm -f a.out

executables: main
  
main: glew.o shader.o luaglfw.o luagl.o src/main.c
	$(CC) $(DEADCODESTRIP) $(CFLAGS) $(INCLUDES) \
  glew.o shader.o luaglfw.o luagl.o src/main.c \
  $(LFLAGS) $(LIBS) \
  -o main.$(EXEC_EXT) 

luaglfw.o: src/luaglfw.c src/luaglfw.h
	$(CC) -c $(CFLAGS) $(INCLUDES) src/luaglfw.c -o luaglfw.o

luagl.o: src/luagl.c src/luagl.h
	$(CC) -c $(CFLAGS) $(INCLUDES) src/luagl.c -o luagl.o

glew.o: src/glew.c
	$(CC) -c $(CFLAGS) $(INCLUDES) src/glew.c -o glew.o \
  $(LFLAGS) $(LIBS)

shader.o: src/shader.c
	$(CC) -c $(CFLAGS) $(INCLUDES)  src/shader.c -o shader.o
 
clean-objs:
	rm -f glm.o shader.o glew.o luaglfw.o luagl.o
