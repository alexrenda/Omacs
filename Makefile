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

build:
	ocamlbuild -use-ocamlfind -pkgs compiler-libs,compiler-libs.toplevel,lambda-term,str,core -tag thread src/main.byte
	mv main.byte omacs

install: build
	cp omacs /bin
	cp src/.oca.ml ~/.oca.ml.d
