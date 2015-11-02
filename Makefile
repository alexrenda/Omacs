SOURCE_FILE=README.md
OUTPUT_FILE=charter.pdf

COMPILER=pandoc

default: run

COMPILE: $(SOURCE_FILE)
	$(COMPILER) $(SOURCE_FILE) -o $(OUTPUT_FILE)

run: COMPILE
	open $(OUTPUT_FILE)

clean:
	rm charter.pdf
