type t
open Key

(* A callback is a method that was parsed that is later ran as a
 * result of a keypress. It takes in the state, and returns a *)
(* new, updated state (possibly calling api functions along the way) *)
type result = t*OBuffer.t
type callback = t -> OBuffer.t -> result

val create : unit -> t

(* register keypress events - these will primarily be called *)
(* by interpreted code *)
val register_keypress_listener : t -> key -> callback -> t

(* tell the controller about a keypress that should be ran. *)
val keypress : t -> key -> OBuffer.t -> result option
val keypress_and_output : t -> key -> OBuffer.t -> (string * result) option

val eval_file : ?debug:bool -> t -> File.t -> t
val eval_file_and_output : t -> File.t -> (string*t)
