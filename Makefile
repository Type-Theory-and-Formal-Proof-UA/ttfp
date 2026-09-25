.PHONY: build watch clean check jobs html

build:
	typst compile main.typ ttfp-uk.pdf

watch:
	typst watch main.typ ttfp-uk.pdf

# HTML edition, one page per chapter -> site/ (experimental Typst HTML export)
html:
	mkdir -p build
	typst compile --features html --format html main.typ build/book.html
	python3 tools/split_html.py build/book.html site
	cp -f ttfp-uk.pdf site/ 2>/dev/null || true

clean:
	rm -f ttfp-uk.pdf
	rm -rf build site

# --- translation pipeline (tools/ttfp) ----------------------------------
# extract  original PDF -> tools/ttfp/raw + per-part jobs in tools/ttfp/out
extract:
	python3 tools/ttfp/extract.py

# re-split the already extracted text into per-part sources + assignments
jobs: tools/ttfp/jobs.mk

tools/ttfp/jobs.mk: tools/ttfp/prepare.py tools/ttfp/chapters.json tools/ttfp/pageranges.json
	python3 tools/ttfp/prepare.py
	@touch $@

# per-part checks: statement counts vs the original, TODOs, typst compile
check:
	python3 tools/ttfp/assemble.py --check

verify:
	python3 tools/ttfp/verify.py

# merge verified parts into src/chapters/*.typ (only fully covered chapters)
assemble:
	python3 tools/ttfp/assemble.py --all
