type t
type pos = int

val make_from_file : File.t -> int -> int -> t

(* General getters *)
val get_text : t -> string
val get_cursor : t -> pos
val get_mark : t -> pos
val get_col : t -> pos
val get_row : t -> pos
val get_width : t -> int
val get_height : t -> int
val get_view_row : t -> int

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
val set_width : t -> int -> t
val set_height : t -> int -> t
val set_view_row : t -> int -> t

(* Basic text interaction *)
val set_text : t -> string -> t
val insert_char_at_cursor : t -> char -> t
val delete_char_at_cursor : t -> t

(* Basic file operations *)
val write : t -> t
val get_file : t -> File.t


val str_of_buffer : t -> string
