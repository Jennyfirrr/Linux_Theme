# src/fox-ai-snitch/Makefile — links against ../fox-intel/libfox-intel.a.
CXX      ?= g++
CXXFLAGS ?= -std=c++17 -O2 -Wall -Wextra
LIBS     := -lcurl
PREFIX   ?= $(HOME)/.local/bin

FOX_INTEL_DIR := ../fox-intel
FOX_INTEL_LIB := $(FOX_INTEL_DIR)/libfox-intel.a
BIN := fox-ai-snitch

all: $(BIN)

$(BIN): fox-ai-snitch.cpp $(FOX_INTEL_LIB)
	$(CXX) $(CXXFLAGS) fox-ai-snitch.cpp -o $@ -L$(FOX_INTEL_DIR) -lfox-intel $(LIBS)

$(FOX_INTEL_LIB):
	$(MAKE) -C $(FOX_INTEL_DIR) libfox-intel.a

install: all
	@mkdir -p $(PREFIX) && cp $(BIN) $(PREFIX)/ && echo "  + $(BIN) installed to $(PREFIX)"

clean:
	@rm -f $(BIN)

.PHONY: all install clean
