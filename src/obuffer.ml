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

module StringBuffer : OBuffer = struct
  type cur = int
  type buf = {text:string; cursor:cur}

  let make () = {text=""; cursor=0}
  
  let get_text (buf:buf) = buf.text
  let get_cursor (buf:buf) = buf.cursor

  let set_text (buf:buf) (text:string) = {buf with text=text}
  let set_cursor (buf:buf) (cursor:cur) = {buf with cursor=cursor}

  let move_cursor_right (buf:buf) =
    {buf with cursor=buf.cursor + 1}
  let move_cursor_left (buf:buf) =
    {buf with cursor=buf.cursor - 1}
                                  
  let insert_char (buf:buf) (chr:char) =
    let left = String.sub buf.text 0 buf.cursor in
    let right = String.sub buf.text buf.cursor (String.length buf.text - buf.cursor) in
    let new_text = left ^ (String.make 1 chr) ^ right in
    {text=new_text; cursor=buf.cursor + 1}
    
  let delete_char (buf:buf) =
    let left = String.sub buf.text 0 (buf.cursor - 1) in
    let right = String.sub buf.text buf.cursor (String.length buf.text - buf.cursor) in
    let new_text = left ^ right in
    {text=new_text; cursor=buf.cursor - 1}
    
  (* Composed features! *)
    
  let insert_string (buf:buf) (str:string) : buf =
    let b : buf ref = ref buf in
    String.iter (fun c -> b := insert_char !b c) str;
    !b
      
  let rec delete_many_chars (buf:buf) (n:int) : buf =
    if n > 0 then delete_many_chars (delete_char buf) (n - 1)
    else buf
      
end
