(* Close the terminal *)
val close : unit -> unit

(* Run the terminal interface. Returns when close() is called*)
val main : unit -> unit

(* Prompt the user for more information *)
val minibuffer : string -> string

(* looks like you need to call a function from a module to link *)
(* it. .oca.ml calls Terminal.close, so the interpreter will have to *)
(* call do_nothing. *)
val do_nothing : unit -> unit
