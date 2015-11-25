type t
(* types to represent a keypress and a hook. Likely these will just be
 * strings *)
type key = string
type hook = string

(* A callback is a method that was parsed that is later ran as a
 * result of a keypress or hook. It takes in the state, and returns a *)
(* new, updated state (possibly calling api functions along the way) *)
type result = t*OBuffer.t
type callback = t -> OBuffer.t -> result

val create : unit -> t

(* register keypress and hook events - these will primarily be called *)
(* by interpreted code *)
val register_keypress_event : t -> key -> callback -> t
val register_hook : t -> hook -> callback -> t

(* tell the controller about a keypress or hook that should be ran. *)
val keypress : t -> key -> OBuffer.t -> result
val run_hook : t -> hook -> OBuffer.t -> result

val eval_file : t -> File.t -> t
