# FoxML Theme Hub — root Makefile.
#
# Discovers any directory under src/ that contains its own Makefile and
# recurses into it. To add a new C++ component:
#
#   1. mkdir src/fox-foo/
#   2. drop a Makefile in there exposing `all`, `install`, `clean`
#   3. (nothing here changes)
#
# Usage:
#   make             build everything
#   make install     build + copy binaries to ~/.local/bin
#   make clean       remove build artefacts
#   make test        run unit-test targets in each subdir (skips if absent)

# Auto-detect every src/<tool>/Makefile and turn each directory into a
# sub-target. The shell expansion runs once at Makefile parse time, so
# adding a new src/<tool>/Makefile is picked up on the next `make`.
TOOLS := $(patsubst src/%/Makefile,%,$(wildcard src/*/Makefile))

all:     $(addprefix build-,$(TOOLS))
install: $(addprefix install-,$(TOOLS))
clean:   $(addprefix clean-,$(TOOLS))

$(addprefix build-,$(TOOLS)): build-%:
	$(MAKE) --no-print-directory -C src/$* all

$(addprefix install-,$(TOOLS)): install-%:
	$(MAKE) --no-print-directory -C src/$* install

$(addprefix clean-,$(TOOLS)): clean-%:
	$(MAKE) --no-print-directory -C src/$* clean

# `make test` invokes each subdir's `test` target if it has one; subdirs
# without a test target print "no tests" and exit 0 so the umbrella
# target stays green.
test: $(addprefix test-,$(TOOLS))

$(addprefix test-,$(TOOLS)): test-%:
	@if $(MAKE) -n -C src/$* test >/dev/null 2>&1; then \
		$(MAKE) --no-print-directory -C src/$* test; \
	else \
		echo "  - src/$*: no tests"; \
	fi

list:
	@printf "Discovered tools:\n"
	@for t in $(TOOLS); do printf "  - %s\n" "$$t"; done

.PHONY: all install clean test list $(addprefix build-,$(TOOLS)) $(addprefix install-,$(TOOLS)) $(addprefix clean-,$(TOOLS)) $(addprefix test-,$(TOOLS))
