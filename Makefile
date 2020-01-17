# ======================================================================
# Makefile - creates PDF, HTML, and plain text files from Markdown
# ======================================================================

# HTML Tidy configuration file
TIDYCONF = $(HOME)/.tidy/html5.conf

# Commands
PANDOC = $(HOME)/opt/pandoc-2.7.3/bin/pandoc
TIDY   = $(HOME)/opt/tidy-html5-5.7.27/bin/tidy
SED    = sed
QPDF   = qpdf

# Command options
PANDOC_FLAGS = --highlight-style=haddock \
    --from=markdown-implicit_figures-fancy_lists
TIDY_FLAGS   = -config $(TIDYCONF)
QPDF_FLAGS   = --linearize

# Options affecting specific writers
html5 = --to=html5 --template=templates/default
latex = --to=latex
plain = --to=plain

# Fixes HTML Tidy output (assumes "css-prefix: tidy")
sed_type = 's/<style type="text\/css">/<style>/'
sed_html = -e $(sed_type)

# List of files to build
files = \
    $(addprefix docs/index.,pdf html txt) \
    $(addprefix docs/example.,pdf html txt)

# ======================================================================
# Pattern Rules
# ======================================================================

VPATH = src:templates

%.html: %.md default.html5
	$(PANDOC) $(PANDOC_FLAGS) $(html5) --output=$@ $<

docs/%.html: %.html
	$(TIDY) $(TIDY_FLAGS) $< | $(SED) $(sed_html) > $@

%.pdf: %.md
	$(PANDOC) $(PANDOC_FLAGS) $(latex) --output=$@ $<

docs/%.pdf: %.pdf
	$(QPDF) $(QPDF_FLAGS) $< $@

docs/%.txt: %.md
	$(PANDOC) $(PANDOC_FLAGS) $(plain) --output=$@ $<

# ======================================================================
# Explicit rules
# ======================================================================

.PHONY: all clean

all: $(files)

clean:
	rm -f docs/*.*
