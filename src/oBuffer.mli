type t
type pos

val make_from_file : File.t -> t

(* General getters *)
val get_text : t -> string
val get_cursor : t -> pos
val get_mark : t -> pos
val get_col : t -> pos
val get_row : t -> pos

(* Basic cursor interaction *)
val set_cursor : t -> pos -> t
val move_cursor_right : t -> t
val move_cursor_left : t -> t
val move_cursor_up : t -> t
val move_cursor_down : t -> t
val move_cursor_to_beginning : t -> t
val move_cursor_to_end : t -> t

val set_col : t -> pos -> t
val set_row : t -> pos -> t

(* Basic text interaction *)
val set_text : t -> string -> t
val insert_char_at_cursor : t -> char -> t
val delete_char_at_cursor : t -> t

(* Basic file operations *)
val write : t -> t
val get_file : t -> File.t
