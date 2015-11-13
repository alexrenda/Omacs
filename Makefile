default: run

%.pdf: %.md
	pandoc $< -o $@

docs: $(patsubst %,%.pdf, readme design)

%.png: %.dot
	dot $< -Tpng -o $@

graphs: $(patsubst %,%.png, mdd candc)

run: graphs docs

clean:
	rm *.pdf *.p
