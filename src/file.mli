type t

val file_of_string : string -> t

val get_contents : t -> string
val get_name : t -> string
val get_path : t -> string

val write_string : t -> string -> unit
