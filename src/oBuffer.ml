open Core
open File

type pos = char Doubly_linked.Elt.t option
type t = {text:char Doubly_linked.t; mutable cursor:pos; mutable mark:pos; file:File.t}

let make_from_file file = 
    let text = Doubly_linked.create () in
    let cursor = Doubly_linked.insert_first text ' ' in
    {text=text; cursor=Some cursor; mark=Some cursor; file=file}

let get_text (buf:t) = 
    let concat accum c = accum^(Char.escaped c) in
    Doubly_linked.fold buf.text ~f:concat ~init:""
let get_cursor (buf:t) = buf.cursor
let get_mark (buf:t) = buf.mark

let set_cursor (buf:t) (pos:pos) =
    buf.cursor <- pos;
    buf
let move_cursor_right (buf:t) =
    match buf.cursor with
    | Some c ->
        if not (Doubly_linked.is_last buf.text c) then 
            buf.cursor <- Doubly_linked.next buf.text c;
        buf
    | None -> failwith "Bad cursor"

let move_cursor_left (buf:t) =
    match buf.cursor with
    | Some c -> 
        if not (Doubly_linked.is_first buf.text c) then 
            buf.cursor <- Doubly_linked.prev buf.text c;
        buf
    | None -> failwith "Bad cursor"

let set_text (buf:t) (text:string) = 
    Doubly_linked.clear buf.text;
    String.iter (fun c -> ignore(Doubly_linked.insert_last buf.text c)) (text^" ");
    let cursor = Doubly_linked.last_elt buf.text in
    buf.cursor <- cursor;
    buf.mark <- cursor;
    buf

let insert_char_at_cursor (buf:t) (chr:char) =
  match buf.cursor with 
  | Some c -> 
          ignore(Doubly_linked.insert_before buf.text c chr);
          buf
  | None -> failwith "Bad cursor"

let delete_char_at_cursor (buf:t) =
  match buf.cursor with 
  | Some c -> 
          if not (Doubly_linked.is_last buf.text c) then ( 
              buf.cursor <- Doubly_linked.next buf.text c;
              Doubly_linked.remove buf.text c);
          buf
  | None -> failwith "Bad cursor" 

let write (buf:t) =
  File.write_string buf.file (get_text buf);
  buf

let get_file (buf:t) = buf.file

