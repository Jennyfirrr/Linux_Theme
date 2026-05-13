# src/fox-render/Makefile — concurrent template renderer.

CXX      ?= g++
CXXFLAGS ?= -std=c++17 -O3 -Wall -Wextra -pthread
LDFLAGS  ?= -pthread
PREFIX   ?= $(HOME)/.local/bin

OBJ = palette.o render.o
BIN = fox-render-fast

all: $(BIN)

palette.o: palette.cpp palette.hpp
	$(CXX) $(CXXFLAGS) -c palette.cpp -o $@

render.o: render.cpp render.hpp
	$(CXX) $(CXXFLAGS) -c render.cpp -o $@

$(BIN): fox-render-fast.cpp $(OBJ)
	$(CXX) $(CXXFLAGS) fox-render-fast.cpp $(OBJ) -o $@ $(LDFLAGS)

install: all
	@mkdir -p $(PREFIX)
	@cp $(BIN) $(PREFIX)/
	@echo "  + $(BIN) installed to $(PREFIX)"

test: tests/test_main
	@./tests/test_main

tests/test_main: tests/test_main.cpp $(OBJ)
	$(CXX) $(CXXFLAGS) tests/test_main.cpp $(OBJ) -o $@ $(LDFLAGS)

clean:
	@rm -f $(OBJ) $(BIN) tests/test_main

.PHONY: all install clean test
