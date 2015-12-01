type t
type pos
type mark = pos option

val make_from_file : File.t -> int -> int -> t

(* General getters *)
val get_text : t -> string
val get_cursor : t -> pos
val get_char_at_cursor : t -> char
val get_mark : t -> mark
val get_col : t -> int
val get_row : t -> int
val get_width : t -> int
val get_height : t -> int
val get_view_row : t -> int

(* Basic cursor interaction *)
val move_cursor_right : t -> t
val move_cursor_left : t -> t
val move_cursor_up : t -> t
val move_cursor_down : t -> t
val move_cursor_to_beginning : t -> t
val move_cursor_to_end : t -> t

val set_col : t -> int -> t
val set_row : t -> int -> t
val set_width : t -> int -> t
val set_height : t -> int -> t
val set_view_row : t -> int -> t
val set_mark : t -> t
val unset_mark : t -> t

(* Basic text interaction *)
val set_text : t -> string -> t
val insert_char_at_cursor : t -> char -> t
val insert_text_at_cursor : t -> string -> t
val delete_char_at_cursor : t -> t

val yank_text_between_positions : t -> pos -> pos -> (string*t)
val copy_text_between_positions : t -> pos -> pos -> (string*t)

(* Basic file operations *)
val write : t -> t
val get_file : t -> File.t


val str_of_buffer : t -> string
