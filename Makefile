.PHONY: all, install

# Seems that we unfortunately must use llvm or else we get issues trying to
# include the Foundation headers
CXX=llvm-g++
C=llvm-gcc

EIGEN=/opt/local/include/eigen3/
EIGEN3_INC=-I$(EIGEN) -I$(EIGEN)/unsupported

LIBIGL=/usr/local/igl/libigl/
LIBIGL_LIB=-L$(LIBIGL)/lib -ligl -liglmatlab
LIBIGL_INC=-I $(LIBIGL)/include

# Do not use the GLU that comes with the macports Mesa:
# http://www.alecjacobson.com/weblog/?p=2827
GLU=/usr/local/
GLU_INC=-I$(GLU)/include
GLU_LIB=-L$(GLU)/lib -lGLU

MESA=/opt/local/
MESA_INC=-I$(MESA)/include
MESA_LIB=-L$(MESA)/lib -lOSMesa -lGL

OBJC_LIB=-lobjc

all: obj Mesh.qlgenerator
install:
	rm -rf /Library/QuickLook/Mesh.qlgenerator
	cp -R Mesh.qlgenerator /Library/QuickLook/Mesh.qlgenerator
	qlmanage -r
	qlmanage -r cache

#CFLAGS += -Wall -g -O0
# openmp is unfortunately not supported by llvm
CFLAGS += -O3 -Wall -DNDEBUG -Winvalid-pch -m64 -msse4.2

CPP_FILES=$(wildcard src/*.cpp)
C_FILES=$(wildcard src/*.c)
M_FILES=$(wildcard src/*.m)
OBJ_FILES=$(addprefix obj/,$(notdir $(CPP_FILES:.cpp=.o))) \
  $(addprefix obj/,$(notdir $(M_FILES:.m=.o))) \
  $(addprefix obj/,$(notdir $(C_FILES:.c=.o)))

LIB+=$(LIBIGL_LIB) $(GLU_LIB) $(MESA_LIB) $(OBJC_LIB) -framework Foundation \
  -framework AppKit -framework QuickLook
INC+=$(EIGEN3_INC) $(LIBIGL_INC) $(GLU_INC) $(MESA_INC)

.PHONY:

Mesh.qlgenerator: Mesh.qlgenerator/Contents/MacOS/ \
  Mesh.qlgenerator/Contents/Resources/ \
  Mesh.qlgenerator/Contents/MacOS/Mesh \
  Mesh.qlgenerator/Contents/Info.plist

Mesh.qlgenerator/Contents/Info.plist: Info.plist
	cp Info.plist Mesh.qlgenerator/Contents/Info.plist

Mesh.qlgenerator/Contents/MacOS/:
	mkdir -p $@

Mesh.qlgenerator/Contents/Resources/:
	mkdir -p $@

Mesh.qlgenerator/Contents/MacOS/Mesh: $(OBJ_FILES)
	${CXX} $(CFLAGS) -bundle -o $@ $(OBJ_FILES) $(LIB)

obj:
	mkdir -p obj

obj/%.o: src/%.cpp src/%.h
	${CXX} $(CFLAGS) -o $@ -c $< $(INC) 

obj/%.o: src/%.m
	${CXX} $(CFLAGS) -o $@ -c $< $(INC)

obj/%.o: src/%.c
	${C} $(CFLAGS) -o $@ -c $< $(INC)

clean:
	rm -f $(OBJ_FILES)
	rm -rf Mesh.qlgenerator
