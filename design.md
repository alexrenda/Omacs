# Omacs Design Doc

## System Description


Omacs is intended to be an OCaml-based extensible, customizable text
editor-- and more. At its core will be a simple buffer-based text
editor, with the possibility of having arbitrary function be run on
the contents of the buffer, taking into account the state of the text
editor and file that it represents. Naturally, we intend for the
editor to have the capabilities to be just as customizable as its
namesake, while also being just as elegant to use. The features of
Omacs include:

* An extensive (and intuitive) collection of built-in keyboard
  shortcuts that would allow the user to quickly perform common
  operations, e.g. cut/paste, find/replace, navigation, etc.

 * Omacs would also feature a tutorial, similar to GNU Emacs' tutorial
   or vimtutor, in order to teach users various commands, while also
   providing an exhaustive documentation of the built-in
   keybindings. The tutorial will be user editable so it can evolve
   alongside the program, should the user choose to implement any
   added functionality to Omacs.

* Content-sensitive editing modes, including support for a variety of
  file types including plain text and OCaml source code.

* Highly customizable, using OCaml code to replace or supplement
  built-in Omacs functionality. Our plan is to have this interpreted
  at run time, using Ocaml's built in interpreter (i.e. whatever the
  toplevel / utop uses). If this isn't feasible, we will make it so
  that the new functionality can be easily compiled in, but ideally we
  want to have it be interpreted.

* This code will have the option of adding new keyboard shortcuts,
  overriding core functions, and adding hooks onto previously existing
  functions

* Some number of other extensions to show the extent of what can be
  implemented with Omacs. This will possibly include a rudimentary
  mail client or web browser.

Omacs is intended to be an all inclusive text editor. As with other
editors, the critical underlying data structure is the the text
buffer, which stores the text being edited in the Omacs environment,
and is written to the disk at the users command. We intend to
implement the buffer by making use of OCaml's exciting mutability
features. Unlike Emacs, there is no plan for Omacs to have any
graphical interface-- it is entirely terminal based. We believe that
Omacs would serve as a viable alternative text editor, and perhaps a
favorite to OCaml developers around the world.


##Architecture
What are the components and connectors? Include a components and
connectors (C&C) diagram. 

## System Design
What are the important modules that will be implemented? What is the
purpose of each module? Include a module dependency diagram (MDD).
![MDD](mdd.png)

##Module Design 
What is the interface to each module? Write a .mli file making each
interface precise with names, types, and brief specifications (which
you will plan to elaborate later); submit a zip file named
interfaces.zip containing those .mli files along with your design
document. 

##Data 
The primary data that we store is the contents of the
buffer. Currently, we plan on storing that in a LinkedList - even
though strings are normally represented as arrays, since we plan on
supporting insertion and deletion at abitrary points inside the
string, and we will naturally be keeping track of the cursor position
(as a node within the LinkedList), we think this will the most
appropriate structure. We're also considering using trying out a list
(array?) of strings, which would give us slightly better performance
for some operations (skpping to a specific point in a file), but would
be much harder to maintain, and wouldn't be faster for all operations.

##Interpretation

##External Dependencies
The external dependencies we plan on using for Omacs  are:

 * Curses - For terminal display
 * compiler-libs (not really external, but must be specially included) - For interpretation



##Testing Plan
The majority of our testing is real-world use. Ideally we get Omacs to a working state ASAP, then we start writing Omacs using Omacs. This obviously won't be perfectly realistic, but if we can manage to use Omacs the majority of the time that we develop Omacs, we expect to end up with a very usable program.