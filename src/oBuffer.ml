type pos = int
type t = {text:string; cursor:pos; mark:pos; file:File.t}

let make_from_file file = {text=""; cursor=0; mark=0; file=file}

let get_text (buf:t) = buf.text
let get_cursor (buf:t) = buf.cursor
let get_mark (buf:t) = buf.mark

let set_cursor (buf:t) (pos:pos) =
  {buf with cursor=pos}
let move_cursor_right (buf:t) =
  {buf with cursor=buf.cursor + 1}
let move_cursor_left (buf:t) =
  {buf with cursor=buf.cursor - 1}

let set_text (buf:t) (text:string) = {buf with text=text}

let insert_char_at_cursor (buf:t) (chr:char) =
  let left = String.sub buf.text 0 buf.cursor in
  let right = String.sub buf.text buf.cursor (String.length buf.text - buf.cursor) in
  let new_text = left ^ (String.make 1 chr) ^ right in
  {text=new_text; cursor=buf.cursor + 1; mark=buf.mark; file=buf.file}

let delete_char_at_cursor (buf:t) =
  let left = String.sub buf.text 0 (buf.cursor - 1) in
  let right = String.sub buf.text buf.cursor (String.length buf.text - buf.cursor) in
  let new_text = left ^ right in
  {text=new_text; cursor=buf.cursor - 1; mark=buf.mark; file=buf.file}

let write (buf:t) =
  File.write_string buf.file buf.text;
  buf

let get_file (buf:t) = buf.file

(* Composed features! *)

let insert_string (buf:t) (str:string) : t =
  let b : t ref = ref buf in
  String.iter (fun c -> b := insert_char_at_cursor !b c) str;
  !b

let rec delete_many_chars (buf:t) (n:int) : t =
  if n > 0 then delete_many_chars (delete_char_at_cursor buf) (n - 1)
  else buf
