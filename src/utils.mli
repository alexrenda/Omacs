val capture_output :  ('a->'b) -> 'a -> string*'b
val capture_output_option : ('a->'b option) -> 'a -> (string*'b) option
val to_string_compact : LTerm_key.t -> string
(* see terminal.mli *)
val do_nothing : unit -> unit

module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
  end

module Option : (Monad with type 'a t = 'a option)
