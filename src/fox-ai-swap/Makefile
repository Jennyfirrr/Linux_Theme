# src/fox-ai-swap/Makefile

CXX      ?= g++
CXXFLAGS ?= -std=c++17 -O3 -Wall -Wextra
PREFIX   ?= $(HOME)/.local/bin

BIN = fox-ai-swap

all: $(BIN)

$(BIN): fox-ai-swap.cpp
	$(CXX) $(CXXFLAGS) fox-ai-swap.cpp -o $@

install: all
	@mkdir -p $(PREFIX)
	@cp $(BIN) $(PREFIX)/
	@echo "  + $(BIN) installed to $(PREFIX)"

clean:
	@rm -f $(BIN)

.PHONY: all install clean
