# ======================================================================
# Makefile - creates PDF, HTML, and plain text files from Markdown
# ======================================================================

# Commands
PANDOC   = $(HOME)/opt/pandoc-2.11.0.4/bin/pandoc
TIDY     = tidy
SED      = sed
QPDF     = qpdf
COMPRESS = yui-compressor

# Markdown flavor and syntax highlighting style
flavor = markdown-implicit_figures-fancy_lists
syntax = haddock

# Command options
PANDOC_FLAGS = --data-dir=pandoc --standalone --from=$(flavor) \
    --highlight-style=$(syntax)
QPDF_FLAGS = --linearize --deterministic-id

# Options affecting specific writers
html5 = --to=html5
latex = --to=latex --resource-path=docs
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

# List of targets
targets = $(addprefix docs/,styles/style.css \
    $(addprefix index,.pdf .html .txt) \
    $(addprefix example,.pdf .html .txt))

# ======================================================================
# Pattern Rules
# ======================================================================

%.html: src/%.md pandoc/templates/default.html5
	$(PANDOC) $(PANDOC_FLAGS) $(html5) --output=$@ $<

docs/%.html: %.html
	$(TIDY) $(tidy_html) $< | $(SED) $(sed_html) > $@

%.pdf: src/%.md pandoc/templates/default.latex
	$(PANDOC) $(PANDOC_FLAGS) $(latex) --output=$@ $<

docs/%.pdf: %.pdf
	$(QPDF) $(QPDF_FLAGS) $< $@

docs/%.txt: src/%.md
	$(PANDOC) $(PANDOC_FLAGS) $(plain) --output=$@ $<

# ======================================================================
# Explicit rules
# ======================================================================

.PHONY: all clean

all: $(targets)

docs/styles/style.css: src/custom.css src/site.css
	$(COMPRESS) $< > $@
	$(COMPRESS) $(word 2,$^) >> $@

clean:
	rm -f docs/*.* docs/styles/style.css
