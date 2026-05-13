# src/fox-install/Makefile — C++ orchestrator.
#
# Every .cpp under core/ and modules/ is compiled and linked into one
# binary. To add a new module, drop a .cpp into modules/ and add one
# line to core/modules.def — no Makefile changes needed.

CXX      ?= g++
CXXFLAGS ?= -std=c++17 -O2 -Wall -Wextra
PREFIX   ?= $(HOME)/.local/bin

CORE_SRC    := $(wildcard core/*.cpp)
MODULE_SRC  := $(wildcard modules/*.cpp)
MAIN_SRC    := fox-install.cpp

CORE_OBJ    := $(CORE_SRC:.cpp=.o)
MODULE_OBJ  := $(MODULE_SRC:.cpp=.o)
MAIN_OBJ    := $(MAIN_SRC:.cpp=.o)

BIN := fox-install

all: $(BIN)

$(BIN): $(MAIN_OBJ) $(CORE_OBJ) $(MODULE_OBJ)
	$(CXX) $(CXXFLAGS) -o $@ $^

# Generic rule covers everything; registry.cpp picks up modules.def
# automatically via #include in registry.cpp.
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Header dependency: anything that includes core/module.hpp pulls in
# core/modules.def transitively. Re-tag registry.cpp explicitly so a
# modules.def edit triggers a rebuild.
core/registry.o: core/registry.cpp core/module.hpp core/modules.def

install: all
	@mkdir -p $(PREFIX)
	@cp $(BIN) $(PREFIX)/
	@echo "  + $(BIN) installed to $(PREFIX)"

test: tests/test_registry
	@./tests/test_registry

# Test binary links only core/registry.o (the X-macro table); modules
# are stubbed inside the test file so we don't drag in their real
# implementations.
tests/test_registry: tests/test_registry.cpp core/registry.o
	$(CXX) $(CXXFLAGS) tests/test_registry.cpp core/registry.o -o $@

clean:
	@rm -f $(BIN) $(CORE_OBJ) $(MODULE_OBJ) $(MAIN_OBJ) tests/test_registry

.PHONY: all install clean test
