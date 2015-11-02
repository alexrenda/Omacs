# Omacs
Emacs in OCaml

##Authors
- Alex Renda - [_adr74_](mailto:adr74@cornell.edu)
- Mustafa Ansari - [_maa296_](mailto:maa296@cornell.edu)
- Zander Bolgar - [_asb322_](mailto:asb322@cornell.edu)

##Meeting Plan
We plan on meeting at least twice a week, and likely more often. Since we're on the same project team which already has biweekly meetings, we plan on meeting before or after those to discuss the project. When we get to the implementation phase, we plan on adding more meeting times as necessary.

##Design Proposal

Omacs - Emacs in OCaml.

We want to make an ocaml-based extensible, customizable text editor - and more. At its core will be a simple buffer-based text editor, with the possibility of having arbitrary function be run on the contents of the buffer, taking into account the state of the text editor and file that it represents. The features of Omacs include:

* Content-sensitive editing modes, including support for a variety of file types including plain text and OCaml source code.

* Highly customizable, using OCaml code to replace or supplement built-in Omacs functionality. Our plan is to have this interpreted at run time, using Ocaml's built in interpreter (i.e. whatever the toplevel / utop uses). If this isn't feasible, we will make it so that the new functionality can be easily compiled in, but ideally we want to have it be interpreted.

    * This code will have the option of adding new keyboard shortcuts, overriding core functions, and adding hooks onto previously existing functions

* Some number of other extensions to show the extent of what can be implemented with Omacs. This will possibly include a rudimentary mail client or webbrowser.
