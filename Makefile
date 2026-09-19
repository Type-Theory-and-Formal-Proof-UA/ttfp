.PHONY: build watch clean

build:
	typst compile main.typ ttfp-uk.pdf

watch:
	typst watch main.typ ttfp-uk.pdf

clean:
	rm -f ttfp-uk.pdf
