.PHONY: build watch clean check jobs

build:
	typst compile main.typ ttfp-uk.pdf

watch:
	typst watch main.typ ttfp-uk.pdf

clean:
	rm -f ttfp-uk.pdf

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
