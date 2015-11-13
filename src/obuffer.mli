type t
type pos

val make_from_file : File.t -> t

(* General getters *)
val get_text : t -> string
val get_cursor : t -> pos
val get_mark : t -> pos

(* Basic cursor interaction *)
val set_cursor : t -> pos -> t
val move_cursor_right : t -> t
val move_cursor_left : t -> t

(* Basic text interaction *)
val set_text : t -> string -> t
val insert_char_at_curor : t -> char -> t
val delete_char_at_cursor : t -> t

(* Basic file operations *)
val write : t -> unit
val get_file : t -> File.t
