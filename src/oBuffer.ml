open Core

type pos = char Doubly_linked.Elt.t option
type t = {text:char Doubly_linked.t; cursor:pos; mark:pos; file:File.t}

let make_from_file file = {text=Doubly_linked.create (); 
                           cursor=None; 
                           mark=None; 
                           file=file}

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

