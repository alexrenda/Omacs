open Core
open File

type pos = int
type mark = pos option
type elt = char Doubly_linked.Elt.t option
type t = {text:char Doubly_linked.t;
          mutable cursor:(elt*pos);
          mutable mark:(elt*pos) option;
          file:File.t}

let (>>=) = Option.bind

let elt_of_int lst count =
  let rec traverse l elt num =
    match elt with
    |Some c ->
      if num = 0 then
        Some c
      else
        traverse l (Doubly_linked.next l c) (num-1)
    |None -> None
  in
  traverse lst (Doubly_linked.first_elt lst) count


let make_from_file file cur mar =
  let text = Doubly_linked.create () in
  (*let cursor = Doubly_linked.insert_first text ' ' in*)
  let start = (None, 0) in
  {text=text; cursor=start; mark=None; file=file}

let get_text (buf:t) =
  let concat accum c = accum^(Char.escaped c) in
  Doubly_linked.fold buf.text ~f:concat ~init:""

let get_cursor (buf:t) = snd buf.cursor

let get_mark (buf:t) : mark = buf.mark
                              >>= fun (_, pos) ->
                              Some pos

let set_cursor (buf:t) (pos:pos) =
  buf.cursor <- (elt_of_int buf.text pos, pos);
  buf

let move_cursor_right (buf:t) =
  match fst buf.cursor with
  | Some c ->
     if not (Doubly_linked.is_last buf.text c) then
       buf.cursor <- (Doubly_linked.next buf.text c, (snd buf.cursor)+1);
     buf
  | None -> buf

let move_cursor_left (buf:t) =
  match fst buf.cursor with
  | Some c ->
     if not (Doubly_linked.is_first buf.text c) then
       buf.cursor <- (Doubly_linked.prev buf.text c, (snd buf.cursor)-1);
     buf
  | None ->
     if snd buf.cursor <> 0 then
       buf.cursor <- (Doubly_linked.last_elt buf.text, (snd buf.cursor)-1);
     buf


let set_text (buf:t) (text:string) =
  Doubly_linked.clear buf.text;
  String.iter (fun c -> ignore(Doubly_linked.insert_last buf.text c)) text;
  let cursor = Doubly_linked.first_elt buf.text in
  buf.cursor <- (cursor, 0);
  buf.mark <- None;
  buf

let insert_char_at_cursor (buf:t) (chr:char) =
  match fst buf.cursor with
  | Some c ->
     ignore(Doubly_linked.insert_before buf.text c chr);
     buf
  | None ->
     ignore(Doubly_linked.insert_last buf.text chr);
     buf.cursor <- (fst buf.cursor, (snd buf.cursor)+1);
     buf

let insert_text_at_cursor (buf:t) (str:string) : t =
  let get = String.get str in
  let len = String.length str in
  let rec insert_text_at_cursor_helper buf idx =
    if idx = len then
      buf
    else
      let buf = get idx |> (insert_char_at_cursor buf) in
      insert_text_at_cursor_helper buf (idx + 1)
  in
  insert_text_at_cursor_helper buf 0

let delete_char_at_cursor (buf:t) =
  match fst buf.cursor with
  | Some c ->
     buf.cursor <- (Doubly_linked.next buf.text c, snd buf.cursor);
     Doubly_linked.remove buf.text c;
     buf
  | None -> buf


let write (buf:t) =
  File.write_string buf.file (get_text buf);
  buf

let get_file (buf:t) = buf.file



let str_of_buffer (buf:t) = failwith "Unimplemented"
let set_view_row (buf:t) = failwith "Unimplemented"
let set_height (buf:t) (height:int) = failwith "Unimplemented"
let set_width (buf:t) (width:int) = failwith "Unimplemented"
let set_row (buf:t) (pos:pos) = failwith "Unimplemented"
let set_col (buf:t) (pos:pos) = failwith "Unimplemented"
let set_mark (buf:t) = failwith "Unimplemented"
let unset_mark (buf:t) = failwith "Unimplemented"
let move_cursor_to_end (buf:t) = failwith "Unimplemented"
let move_cursor_to_beginning (buf:t) = failwith "Unimplemented"
let move_cursor_down (buf:t) = failwith "Unimplemented"
let move_cursor_up (buf:t) = failwith "Unimplemented"
let get_view_row (buf:t) = failwith "Unimplemented"
let get_height (buf:t) = failwith "Unimplemented"
let get_width (buf:t) = failwith "Unimplemented"
let get_row (buf:t) = failwith "Unimplemented"
let get_col (buf:t) = failwith "Unimplemented"
let get_char_at_cursor (buf:t) = failwith "Unimplemented"
let yank_text_between_positions (buf:t) (pos1:pos) (pos2:pos) = failwith "Unimplemented"
let copy_text_between_positions (buf:t) (pos1:pos) (pos2:pos) = failwith "Unimplemented"
