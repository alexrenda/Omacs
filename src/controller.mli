type t
(* types to represent a keypress and a hook. Likely these will just be 
 * strings *)
type key
type hook

(* an api function that can be called during interpretation. The *)
(* string is its name, the ('a -> 'b) just guarantees that it's a *)
(* function, with arbitrary types. *)
type ('a, 'b) api_function = string*('a -> 'b)
type callback = OBuffer.t -> OBuffer.t

val create : unit -> t

val register_api_function : ('a, 'b) api_function -> t

val register_keypress_event : key -> callback -> t
val register_hook : hook -> callback -> t

val keypress : key -> OBuffer.t -> OBuffer.t
val run_hook : hook -> OBuffer.t -> OBuffer.t

val eval_file : File.t -> t
