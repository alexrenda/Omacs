(* ignore_output f a returns b where b is the result of f a
 * Any output printed to stdout or stderr is ignored *)
val ignore_output :  ('a->'b) -> 'a -> 'b

(* capture_output f a returns (s, b) where b is the result of f a and *)
(* s is all output printed to stdout and stderr while running f a *)
val capture_output :  ('a->'b) -> 'a -> string*'b
val capture_output_option : ('a->'b option) -> 'a -> (string*'b) option
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
