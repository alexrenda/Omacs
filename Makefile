default: run

%.pdf: %.md *.dot
	pandoc $< -o $@

docs: $(patsubst %,%.pdf, readme design)

%.png: %.dot
	dot $< -Tpng -o $@

graphs: $(patsubst %,%.png, mdd candc)

run: graphs docs

clean:
	rm *.pdf *.p

release: run
	rm omacs.zip || true
	cd src; \
	zip ../omacs.zip *.ml{,i} README.txt run.sh omacstutor test tests/*.ml .cs3110 .oca.ml.d/*.oca.ml .oca.ml.d/.*oca.ml
	git log > vclog.txt
