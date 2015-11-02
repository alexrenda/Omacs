module type OBuffer = sig
  type buf
  type cur

  val make : unit -> buf
  
  (* General getters *)
  val get_text : buf -> string
  val get_cursor : buf -> cur

  (* Basic cursor interaction *)
  val set_cursor : buf -> cur -> buf
  val move_cursor_right : buf -> buf
  val move_cursor_left : buf -> buf

  (* Basic text interaction *)
  val set_text : buf -> string -> buf
  val insert_char : buf -> char -> buf
  val delete_char : buf -> buf
  
end

module StringBuffer : OBuffer
