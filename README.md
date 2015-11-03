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

We want to make an ocaml-based extensible, customizable text editor - and more. At its core will be a simple buffer-based text editor, with the possibility of having arbitrary function be run on the contents of the buffer, taking into account the state of the text editor and file that it represents. Naturally, we intend for the editor to have the capabilities to be just as customizable as its namesake, while also being just as elegant to use. The features of Omacs include:

* An extensive (and intuitive) collection of built-in keyboard shortcuts that would allow the user to quickly perform common operations, e.g. cut/paste, find/replace, navigation, etc.
    
    * Omacs would also feature a tutorial, similar to vimtutor, in order to teach users various commands, while also providing an exhaustive documentation of the built-in keybindings. The tutorial will be user editable so it can evolve alongside the program, should the user choose to implement any added functionality to Omacs.  

* Content-sensitive editing modes, including support for a variety of file types including plain text and OCaml source code.

* Highly customizable, using OCaml code to replace or supplement built-in Omacs functionality. Our plan is to have this interpreted at run time, using Ocaml's built in interpreter (i.e. whatever the toplevel / utop uses). If this isn't feasible, we will make it so that the new functionality can be easily compiled in, but ideally we want to have it be interpreted.

    * This code will have the option of adding new keyboard shortcuts, overriding core functions, and adding hooks onto previously existing functions

* Some number of other extensions to show the extent of what can be implemented with Omacs. This will possibly include a rudimentary mail client or web browser.

Omacs is intended to be an all inclusive text editor. As with other editors, the critical underlying data structure is the the text buffer, which stores the text being edited in the Omacs environment, and is written to the disk at the users command. We intend to implement the buffer by making use of OCaml's exciting mutability features. Unlike Emacs, there is no plan for Omacs to have any graphical interface-- it is entirely terminal based. We believe that Omacs would serve as a viable alternative text editor, and perhaps a favorite to OCaml developers around the world.
