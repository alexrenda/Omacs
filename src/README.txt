Omacs: Emacs in Ocaml

Using the program:
In order to build/run Omacs, simple make sure you are in the omacs directory, use the
run script, and provide the filename of the file you want to edit:

$ ./run.sh <filename>

The run script as well as the provided .cs3110 file included in the source directory
ensure that everything is properly configured to build and run. You can take a look
at those files if you want anymore information

Learning to Edit With Omacs:
If you want a quick crash course in using Omacs(/Emacs) keybindings, feel free to use
the provided omacstutorial:

$ ./run.sh omacstutor

Extending Omacs:
If you'd like to take a look at a typical user defined behavior for Omacs, feel free to
look at the .oca.ml file to take a look at how keypresses are handled, or in the
.oca.ml.d/ directory to see an example of user defined syntax highlighting (the provided
example literally highlights the word 'syntax', but it serves as a proof of concept/
example of the kinds of things you can do with Omacs). If you want to provide your own
ocaml code, make sure to put it in that directory.
