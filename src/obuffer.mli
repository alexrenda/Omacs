module type OBuffer = sig
  type t
  type pos

  (* should this take a string or a file? *)
  val make_from_file : File.t -> t

  (* General getters *)
  val get_text : t -> string
  val get_cursor : t -> pos
  val get_mark : t -> pos

  (* Basic cursor interaction *)
  val set_cursor : t -> pos -> unit
  val move_cursor_right : t -> unit
  val move_cursor_left : t -> unit

  (* Basic text interaction *)
  val set_text : t -> string -> unit
  val insert_char_at_curor : t -> char -> unit
  val delete_char_at_cursor : t -> unit

  (* Basic file operations *)
  val write : t -> unit
  val get_file : t -> File.t
end

module StringBuffer : OBuffer
