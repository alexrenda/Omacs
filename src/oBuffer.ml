open Core

type pos = char Doubly_linked.Elt.t option
type t = {text:char Doubly_linked.t; cursor:pos; mark:pos; file:File.t}

let make_from_file file = {text=Doubly_linked.create (); 
                           cursor=None; 
                           mark=None; 
                           file=file}

let get_text (buf:t) = 
    let concat accum c = accum^(Char.escaped c) in
    Doubly_linked.fold buf.text ~f:concat ~init:""
let get_cursor (buf:t) = buf.cursor
let get_mark (buf:t) = buf.mark

let set_cursor (buf:t) (pos:pos) = {buf with cursor=pos}
let move_cursor_right (buf:t) =
    match buf.cursor with
    | Some c ->
        if Doubly_linked.is_last buf.text c then 
          buf
        else
          {buf with cursor=Doubly_linked.next buf.text c}
    | None -> 
        {buf with cursor=Doubly_linked.first_elt buf.text}
let move_cursor_left (buf:t) =
    match buf.cursor with
    | Some c -> 
        if Doubly_linked.is_first buf.text c then 
          buf
        else
          {buf with cursor=Doubly_linked.prev buf.text c}
    | None -> 
        buf

let set_text (buf:t) (text:string) = 
    let temp = Doubly_linked.create () in
    String.iter (fun c -> ignore(Doubly_linked.insert_last temp c)) text;
    {buf with text=temp; cursor=None; mark=None}

let insert_char_at_cursor (buf:t) (chr:char) =
  match buf.cursor with 
  | Some c -> 
          ignore(Doubly_linked.insert_before buf.text c chr);
          buf
  | None -> 
          ignore(Doubly_linked.insert_first buf.text chr);
          let cursor' = Doubly_linked.first_elt buf.text in
          {buf with cursor=cursor'}

let delete_char_at_cursor (buf:t) =
  match buf.cursor with 
  | Some c -> 
          if Doubly_linked.is_last buf.text c then
              let cursor' = Doubly_linked.prev buf.text c in
              Doubly_linked.remove buf.text c;
              {buf with cursor=cursor'}
          else
              let cursor' = Doubly_linked.next buf.text c in
              Doubly_linked.remove buf.text c;
              {buf with cursor=cursor'}
  | None -> 
          buf

let write (buf:t) =
  File.write_string buf.file (get_text buf);
  buf

let get_file (buf:t) = buf.file

