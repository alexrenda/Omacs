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

* Highly customizable, using OCaml code to replace or supplement
  built-in Omacs functionality. This will be interpreted
  at run time, using Ocaml's built in interpreter (i.e. whatever the
  top-level / utop uses).
  
* This code will have the option of adding new keyboard shortcuts,
  overriding core functions, and adding hooks onto previously existing
  functions

* Some number of other extensions to show the extent of what can be
  implemented with Omacs. This will possibly include a rudimentary
  mail client or web browser.

Omacs is intended to be an all inclusive text editor. As with other
editors, the critical underlying data structure is the text
buffer, which stores the text being edited in the Omacs environment,
and is written to the disk at the users command. We intend to
implement the buffer by making use of OCaml's exciting mutability
features. Unlike Emacs, there is no plan for Omacs to have any
graphical interface-- it is entirely terminal based. We believe that
Omacs will serve as a viable alternative text editor.


##Architecture
At a high level, we intend to have a terminal that would serve as a top-level that displays information to the user and accepts all input. The terminal would be be backed by a buffer which stores all the information about the file being edited-- this includes the actual text stored in the file, as well as information like the position of the cursor, and the file's metadata. We would have a layer in between the terminal and the data that would process the user input and edit/update the information stored in the buffer accordingly. Since we plan for Omacs to be user extensible, there would also be a system running alongside this layer that would interpret arbitrary code provided by the user and change the default editing behavior as necessary.

![C&C](candc.png)

## System Design
The main modules that we plan on implementing are as follows:

* **Terminal**: Curses-based top-level that serves as the front-end for the user. This will have the actual display, handle keypresses, and be the main entry point for the program. This module is the only layer that the user can interact with, and ultimately passes all information to the controller to edit the working buffer. The Terminal module also communicates with the OBuffer, however, it does not edit it directly; the Terminal only talks to the OBuffer to recieve information to display in the window.

* **Controller**: The Controller the module that is responsible for making modifications to the OBuffer on behalf of the user. In order to do this, the controller handles keypresses from the Terminal. By using a map of key events (e.g. C-space) to functions (e.g set mark), the terminal will be able to process user input to update the file.

* **OBuffer**: Actual data storage. The OBuffer will provide some methods for getting and setting the contents of the text buffer, which is the backing data structure for the text editor. It will also include any additional global data about the file being edited.


* **Interpreter**: The Interpreter executes arbitrary Ocaml code defined by the user. Essentially, this will interpret an Ocaml file, and register a set of callbacks that it defines. These callbacks would change the editing behavior of Omacs to the users specification.

![MDD](mdd.png)

The included .mli files provide a deeper overview of Omacs's modular design.

##Data 

### Text Buffer
The primary data that we store is the contents of the
buffer. Currently, we plan on storing that in a LinkedList - even
though strings are normally represented as arrays, since we plan on
supporting insertion and deletion at abitrary points inside the
string, and we will naturally be keeping track of the cursor position
(as a node within the LinkedList), we think this will the most
appropriate structure. Although we feel that a linked list may be the most effective data structure, we are still entertaining the thought of  trying out an array or list of strings, which would give us slightly better performance
for some operations (skpping to a specific point in a file), but would potentially 
be much harder to maintain while not necessarily providing worthwhile improvements.

###Additional Information
Alongside the actual text and cursor position stored in the text buffer, the Obuffer would also store additional information about the file, such as the file name, extension and any other relevant metadata (this information would be useful in order to provide features such as context highlighting for specific filetypes, etc). We would also store information specific to the current editing state, like. marks in the file, or additional buffers (for cutting/pasting, for instance). Since this information would change directly from the controller, and would not be incrementally edited like the files' text, they would be stored in simple structures like Ocaml lists, ints, strings etc.

##Interpretation

For interpretation, we plan on using the compiler-libs module. This will let us control the environment for the interpreted code (so that we can provide helper functions and functions for controlling the state of Omacs), while also allowing us to easily extract the values (callbacks) resulting from interpreting the code.These callbacks can then be incorporated by the controller, or they can directly be run on the contents of the buffer in order to provide Omacs with user defined behavior for editing.

##External Dependencies
The external dependencies we plan on using for Omacs  are:

 * Curses - For the terminal display
 * compiler-libs (not really external, but must be specially included) - For interpretation
 
Aside from these two exceptions, we feel that there should be no problem implementing Omacs with stock Ocaml.

##Testing Plan

###Modular Testing
During development, it would be easy to develop and maintain a suite of unit tests for the individual modules; it is easy to come up with examples of possible tests for the various systems we have planned, for example the Obuffer, Controller and Interpreter modules can be given traditional unit tests to ensure that they function as intended (ie, editing a string in a buffer and comparing the output to the expected result, etc.). Since the terminal is mainly aesthetic and functions by accepting user input, this would likely be tested manually-- opening a sample terminal and ensuring that it properly registers keypresses would be a decent way to ensure that it functions properly.

###System Testing
For the editor as a whole, the majority of our testing would naturally be real world use-- editing actual files and actively searching for bugs and edge cases will shed light on any issues that may reveal themselves once we unify our various modules. In an effort to extensively test our system, we'd ideally get Omacs to a working state as soon as possible, and begin to develop the remaining code in Omacs! Although this may not be perfectly realistic, if we can manage to use Omacs during at least some percent of the time we spend developing Omacs, we expect to be able to test an extremely wide range of use cases.
