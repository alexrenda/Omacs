val capture_output :  ('a->'b) -> 'a -> string*'b
val capture_output_option : ('a->'b option) -> 'a -> (string*'b) option
val to_string_compact : LTerm_key.t -> string
val string_ends_with : string -> string -> bool

module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
  val map : 'a t -> ('a -> 'b) -> 'b t
  val (>>|) : 'a t -> ('a -> 'b) -> 'b t
  end

module Option : (Monad with type 'a t = 'a option)
