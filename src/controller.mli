type t
open Key
(* types to represent a keypress and a hook. Likely these will just be
 * strings *)
type hook =
  | FileOpen
  | FileSave
  | FileClose

(* A callback is a method that was parsed that is later ran as a
 * result of a keypress or hook. It takes in the state, and returns a *)
(* new, updated state (possibly calling api functions along the way) *)
type result = t*OBuffer.t
type callback = t -> OBuffer.t -> result

val create : unit -> t

(* register keypress and hook events - these will primarily be called *)
(* by interpreted code *)
val register_keypress_listener : t -> key -> callback -> t
val register_hook_listener : t -> hook -> callback -> t

(* tell the controller about a keypress or hook that should be ran. *)
val keypress : t -> key -> OBuffer.t -> result option
val run_hook : t -> hook -> OBuffer.t -> result option
val keypress_and_output : t -> key -> OBuffer.t -> (string * result) option
val run_hook_and_output : t -> hook -> OBuffer.t -> (string * result) option

val eval_file : ?debug:bool -> t -> File.t -> t
val eval_file_and_output : t -> File.t -> (string*t)
