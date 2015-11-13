type t
(* types to represent a keypress and a hook. Likely these will just be 
 * strings *)
type key
type hook

(* an api function that can be called during interpretation. The *)
(* string is its name, the ('a -> 'b) just guarantees that it's a *)
(* function, with arbitrary types. *)
type ('a, 'b) api_function = string*('a -> 'b)

(* A callback is a method that was parsed that is later ran as a 
 * result of a keypress or hook. It takes in the state, and returns a *)
(* new, updated state (possibly calling api functions along the way) *)
type result = t*OBuffer.t
type callback = (t*OBuffer.t) -> result

val create : unit -> t

val register_api_function : ('a, 'b) api_function -> t

val register_keypress_event : key -> callback -> t
val register_hook : hook -> callback -> t

val keypress : key -> OBuffer.t -> result
val run_hook : hook -> OBuffer.t -> result

val eval_file : File.t -> t
