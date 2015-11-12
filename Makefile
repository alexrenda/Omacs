default: run

%.pdf: %.md
	pandoc $< -o $@

docs: $(patsubst %,%.pdf, readme design)

%.png: %.dot
	dot $< -Tpng -o $@

graphs: $(patsubst %,%.png, mdd)

run: graphs docs

clean:
	rm charter.pdf
