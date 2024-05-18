LMPACK_VERSION != git describe --tags

# targets
DEPS_BIN ?= /usr/local/bin
LUA ?= $(DEPS_BIN)/luajit
LUAROCKS ?= $(DEPS_BIN)/luarocks
BUSTED ?= $(DEPS_BIN)/busted

# Compilation
CFLAGS ?= -ansi -O0 -g3 -Wall -Wextra -Werror -Wconversion \
	-Wstrict-prototypes -Wno-unused-parameter -pedantic
CFLAGS += -fPIC -std=c99
CFLAGS += -DMPACK_DEBUG_REGISTRY_LEAK
LDFLAGS ?= -L/usr/local/lib -lluajit

INCLUDES = -I/usr/local/include/luajit-2.1 -Ilibmpack/src

# Misc
# Options used by the 'valgrind' target, which runs the tests under valgrind
VALGRIND_OPTS ?= --error-exitcode=1 --log-file=valgrind.log --leak-check=yes \
	--track-origins=yes

all:  mpack.so

clean:
	rm -rf *.tar.gz *.src.rock *.so* *.o

test:
	$(BUSTED) -o gtest test.lua

valgrind: $(BUSTED) $(MPACK)
	valgrind $(VALGRIND_OPTS) $(BUSTED) test.lua

mpack.so: lmpack.c libmpack/src/mpack.c
	$(CC) -shared $(CFLAGS) $(INCLUDES) $(LDFLAGS) $< -o $@ $(LIBS)

.PHONY: all clean depsclean install test gdb valgrind ci-test release
