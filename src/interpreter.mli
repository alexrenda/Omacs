(* TODO: make this Controller.t -> Controller.t
 * maybe do this with a functor? *)
val eval_file : bool -> File.t -> ('a -> 'a)

(* register an api function to be available to interpreted code *)
val register_api_function : string -> ('a -> 'b) -> unit

val write_object : string -> 'a -> unit

val read_object : string -> 'a
