val close : unit -> unit
val main : unit -> unit

(* looks like you need to call a function from a module to link *)
(* it. .oca.ml calls Terminal.close, so the interpreter will have to *)
(* call do_nothing. *)
val do_nothing : unit -> unit
