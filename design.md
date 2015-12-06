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
  shortcuts that allow the user to quickly perform common
  operations, e.g. cut/paste, navigation, etc.

* Omacs also features a tutorial, similar to GNU Emacs' tutorial
   or vimtutor, in order to teach users various commands, while also
   providing an exhaustive documentation of the built-in
   keybindings. The tutorial is user editable so it can evolve
   alongside the program, should the user choose to implement any
   added functionality to Omacs.

* Highly customizable, using OCaml code to replace or supplement
  built-in Omacs functionality. This code is interpreted
  at run time, using Ocaml's built in interpreter (i.e. the Toploop module).

* This code has the option of adding new keyboard shortcuts,
  overriding core functions, and adding hooks onto previously existing
  functions

* Other extensions to show the extent of what can be
  implemented with Omacs. This includes a proof of concept for synax highlighting.

Omacs is intended to be an all inclusive text editor. As with other
editors, the critical underlying data structure is the text
buffer, which stores the text being edited in the Omacs environment,
and is written to the disk at the users command. We implemented the buffer by making use of OCaml's exciting mutability
features. Unlike Emacs, there is no
graphical interface-- Omacs is entirely terminal based. We believe that
Omacs can serve as a viable alternative text editor.


##Architecture
At a high level, we Omacs has a terminal that serves as a top-level that displays information to the user and accepts all input. The terminal is backed by a buffer which stores all the information about the file being edited-- this includes the actual text stored in the file, as well as information like the position of the cursor, and the file's metadata. There is a layer in between the terminal and the data that processes the user input and edits/updates the information stored in the buffer accordingly. Since Omacs is user extensible, there is also a system running alongside this layer that interprets arbitrary code provided by the user and changes the default editing behavior as necessary.

![C&C](candc.png)

## System Design
The modules that we implemented are as follows:

* **Terminal**: Lambda-term-based top-level that serves as the front-end for the user. This has the actual display, handles keypresses, and is the main entry point for the program. This module is the only layer that the user can interact with, and ultimately passes all information to the controller to edit the working buffer. The Terminal module also communicates with the OBuffer, however, it does not edit text directly; the Terminal only talks to the OBuffer to recieve information to display in the window.

* **Controller**: The Controller is the module that is responsible for making modifications to the OBuffer on behalf of the user. In order to do this, the controller handles keypresses from the Terminal. By using a map of key events (e.g. C-space) to functions (e.g set mark), the terminal is able to process user input to update the file.

* **OBuffer**: Actual data storage. The OBuffer provides some methods for getting and setting the contents of the text buffer, which is the backing data structure for the text editor. This buffer is represented using a doubly-linked list of characters,and also stores the styling information for ach character (which can be used, for example, for syntax highlighting). The  It also includes any additional global data about the file being edited, such as the filename and information about the terminal.

* **Interpreter**: The Interpreter executes arbitrary Ocaml code defined by the user. Essentially, this inteprets an Ocaml file, and registers a set of callbacks that it defines. These callbacks would change the editing behavior of Omacs to the users specification.

* **File**: The File module implements all the general file operations that are useful for Omacs to have. Naturally, this module implements functions that allow Omacs to read from/write to a file, explore directories, and obtain a file's metadata.

* **Style**: The Style module is responsible for determining how the text stored in the oBuffer is meant to be rendered to the terminal, based on the size of the terminal window, and the style information stored in the buffer itelf.

* **Key**: The Key module is used to represent keypresses in Omacs, and also provides various helper functions to help manage them.

* **Utils**: Provides useful functions that are used across multiple modules.
![MDD](mdd.png)


##Data

### Text Buffer
The primary data that we store is the contents of the
buffer. It is implemented as a doubly linked list of characters and style information, since we support insertion and deletion at abitrary points inside the
string, and we naturally keep track of the cursor position, which is easy to do when it is represented as a node within a linked list. Most of the operations on the buffer are completed by some compostion of moving the cursor left or right, and deleting the character it points to.

###Additional Information
Alongside the actual text and cursor position stored in the text buffer, the Obuffer also stores additional information about the file, such as the file name, extension and any other relevant metadata (this information is useful in order to provide features such as context highlighting for specific filetypes, etc). We also store information specific to the current editing state, like marks in the file, information about the layout of the terminal.

##Interpretation

For interpretation, we used the compiler-libs module. This lets us control the environment for the interpreted code (so that we can provide helper functions and functions for controlling the state of Omacs), while also allowing us to easily extract the values (callbacks) resulting from interpreting the code.These callbacks are then be incorporated by the controller, or they can directly be run on the contents of the buffer in order to provide Omacs with user defined behavior for editing.

##External Dependencies
The external dependencies we used for Omacs  are:

 * lambda-term - For the terminal display and styling text
 * compiler-libs (not really external, but must be specially included) - For interpretation
 * core (not really external, but must be specially included) - To use the provided doubly linked list implementation
 * str (not really external, but must be specially included) - Needed for string operations

We also drew inspiration from lambda-term for the representation of keys/keypresses, but we implemented this ourselves. Aside from these external modules, the rest of Omacs was written from stock Ocaml.

##Testing Plan (Before Implementation)

###Modular Testing
During development, it would be easy to develop and maintain a suite of unit tests for the individual modules; it is easy to come up with examples of possible tests for the various systems we have planned, for example the Obuffer, Controller and Interpreter modules can be given traditional unit tests to ensure that they function as intended (ie, editing a string in a buffer and comparing the output to the expected result, etc.). Since the terminal is mainly aesthetic and functions by accepting user input, this would likely be tested manually-- opening a sample terminal and ensuring that it properly registers keypresses would be a decent way to ensure that it functions properly.

###System Testing
For the editor as a whole, the majority of our testing would naturally be real world use-- editing actual files and actively searching for bugs and edge cases will shed light on any issues that may reveal themselves once we unify our various modules. In an effort to extensively test our system, we'd ideally get Omacs to a working state as soon as possible, and begin to develop the remaining code in Omacs! Although this may not be perfectly realistic, if we can manage to use Omacs during at least some percent of the time we spend developing Omacs, we expect to be able to test an extremely wide range of use cases.

## Actual Testing (During/After Implementation)

Through development, we were able to follow our initial testing plan reasonably well. While working individual modules, we wrote various unit tests that ensured that the code was functioning properly. By setting up a commit hook that rejected commits that failed to build or pass unit tests, we were able to ensure that the project remained stable and unbroken as we continued to work on it, which was very helpful. As we stated in our plan, we also hoped to have the ability to test the entire system by using Omacs to continue to develop, and we were actually able to achieve this goal towards the end of this project-- in fact, this design document was actually updated in Omacs! To our knowledge, there are currently no bugs in Omacs.


##How to extend Omacs

When Omacs is started, it evaluates every file in ~/.oca.ml.d that ends with ".oca.ml" in alphabetic order (it's important that .oca.ml be ran first). Each of the files must declare a value register_callbacks of type Controller.t -> Controller.t. This function is immediately ran when the file is evaluated.
Inside of each of these register_callbacks, the file may register some keypresses to listen for, and execute callbacks when the keypress is ran. For possible examples, see the ~/.oca.ml.d/.oca.ml