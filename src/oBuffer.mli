(* All of the OBuffer setter functions return a t, but there is no *)
(* guarantee that the OBuffer is immutable. *)

type t
type pos
type mark = pos option

val make_from_file : File.t -> int -> int -> t

(* General getters *)
val get_string : t -> string
val get_char_at_cursor : t -> char option
val get_mark : t -> mark
(* row and col are 1-indexed *)
val get_col : t -> int
val get_row : t -> int
val get_width : t -> int
val get_height : t -> int
(* the top line of the buffer is the first row that's visible *)
val get_top_line : t -> int

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
val set_top_line : t -> int -> t
val set_mark : t -> t
val unset_mark : t -> t

(* Basic text interaction *)
val set_text : t -> string -> t
val insert_char_at_cursor : t -> char -> t
val insert_text_at_cursor : t -> string -> t
val delete_char_before_cursor : t -> t
val delete_char_at_cursor : t -> t
val set_text_style : t -> int -> int -> Style.t list -> t

val yank_text_between_mark_and_cursor : ?kill:bool -> t -> (string*t) option

(* Basic file operations *)
val write : t -> t
val get_file : t -> File.t


(* stylized_text_of_buffer t returns (r, s) where s is a list of *)
(* markup items, of which each String element should be on a separate *)
(* time, and r is the list of line numbers that correspond to each *)
(* line of s (to handle splitting long lines onto different lines) *)
val stylized_text_of_buffer : t -> (int list * Style.stylized_text)
