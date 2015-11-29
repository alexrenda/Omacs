type t

exception File_not_found

val file_of_string : string -> t

val get_contents : t -> string

(* get the name of the file (e.g. "file.mli") *)
val get_name : t -> string

(* get the relative path of the file (e.g. "./file.mli") *)
val get_path : t -> string

(* write the string to the file and flush *)
val write_string : t -> string -> unit
