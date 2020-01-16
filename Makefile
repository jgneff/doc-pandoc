# ======================================================================
# Makefile - creates PDF, HTML, and plain text files from Markdown
# ======================================================================

# Commands
PANDOC = $(HOME)/opt/pandoc-2.7.3/bin/pandoc

# Command options
PANDOC_FLAGS = --from=markdown --highlight-style=haddock

# Options affecting specific writers
html5 = --to=html5 --css=styles/light.min.css --template=src/template
latex = --to=latex
plain = --to=plain

# List of files to build
files = $(addprefix docs/index.,pdf html txt)

# ======================================================================
# Pattern Rules
# ======================================================================

VPATH = src

docs/%.html: %.md template.html5
	$(PANDOC) $(PANDOC_FLAGS) $(html5) --output=$@ $<

docs/%.pdf: %.md
	$(PANDOC) $(PANDOC_FLAGS) $(latex) --output=$@ $<

docs/%.txt: %.md
	$(PANDOC) $(PANDOC_FLAGS) $(plain) --output=$@ $<

# ======================================================================
# Explicit rules
# ======================================================================

.PHONY: all clean

all: $(files)

clean:
	rm -f docs/*.*
