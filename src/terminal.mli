type t

val create : unit -> t
(* show this terminal on the terminal. never returns *)
val show : t -> unit
val open_file : File.t -> unit

(* nicely close the terminal (possible in response to a C-c event? *)
val close : t -> unit
