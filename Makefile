# ======================================================================
# Makefile - creates PDF, HTML, and plain text files from Markdown
# ======================================================================

# Commands
PANDOC = $(HOME)/opt/pandoc-2.7.3/bin/pandoc
TIDY   = $(HOME)/opt/tidy-html5-5.7.27/bin/tidy
SED    = sed
QPDF   = qpdf

# Markdown flavor and syntax highlighting style
flavor = markdown-implicit_figures-fancy_lists
style = haddock

# Command options
PANDOC_FLAGS = --from=$(flavor) --highlight-style=$(style)
QPDF_FLAGS   = --linearize

# Options affecting specific writers
html5 = --to=html5 --template=templates/default
latex = --to=latex
plain = --to=plain

# HTML Tidy options
# https://api.html-tidy.org/tidy/quickref_next.html
css_prefix = tidy
tidy_html = --quiet yes --force-output yes --tidy-mark no --wrap 0 \
    --add-meta-charset yes --doctype html5 --output-html yes \
    --clean yes --quote-nbsp no --css-prefix $(css_prefix) \
    --enclose-block-text yes --enclose-text yes --hide-comments yes

# Fixes HTML Tidy output
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
	$(TIDY) $(tidy_html) $< | $(SED) $(sed_html) > $@

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
