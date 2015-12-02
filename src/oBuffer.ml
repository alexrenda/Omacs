open Utils
open File
module Doubly_linked = Core.Doubly_linked

type pos = int
type mark = pos option
type char_rep = char * Style.t list
type elt = char_rep Doubly_linked.Elt.t option
type t = {text:char_rep Doubly_linked.t;
          mutable cursor:(elt*pos);
          mutable col:pos;
          mutable row:pos;
          mutable mark:(elt*pos);
          mutable height:int;
          mutable width:int;
          mutable top_line:int;
          file:File.t}

(* Helpful functions *)
let (>>=) = Option.bind
let (>>|) = Option.map

let elt_of_int (lst:char_rep Doubly_linked.t) (count:int) : elt =
  let rec traverse l elt num =
    elt
    >>= fun c ->
    if num = 0 then
      Some c
    else
      traverse l (Doubly_linked.next l c) (num-1)
  in
  traverse lst (Doubly_linked.first_elt lst) count

let rec fold_between f acc lst start finish =
  if start = finish then
    acc
  else
    let elt = start in
    match Doubly_linked.next lst start with
    | Some next ->
       let acc = f acc elt in
       fold_between f acc lst next finish
    | None -> failwith "index out of bounds"

let correct_col buf : unit =
  let rec normalize_col_helper dist prev =
    match prev with
    | Some elt ->
       let value, _ = Doubly_linked.Elt.value elt in
       if value = '\n' then
         dist
       else
         normalize_col_helper (dist + 1) (Doubly_linked.prev buf.text elt)
    | None -> dist
  in
  match fst buf.cursor with
  | Some elt ->
     buf.col <- normalize_col_helper 1 (Doubly_linked.prev buf.text elt)
  | None ->
     let last = Doubly_linked.last_elt buf.text in
     buf.col <- normalize_col_helper 1 last

let correct_row_and_col buf : unit =
  let dest_elt = fst buf.cursor in
  let rec normalize_row_helper curr_col curr_row curr_elt =
    match (curr_elt, dest_elt) with
    | None, None -> curr_col, curr_row
    | Some elt, Some dest when elt = dest -> curr_col, curr_row
    | Some elt, _ ->
       let v, _ = Doubly_linked.Elt.value elt in
       let next_elt = Doubly_linked.next buf.text elt in
       if v = '\n' then
         let next_row = curr_row + 1 in
         let next_col = 1 in
         normalize_row_helper next_col next_row next_elt
       else
         let next_col = curr_col + 1 in
         if next_col > buf.width then
           let next_col = 1 in
           let next_row = curr_row + 1 in
           normalize_row_helper next_col next_row next_elt
         else
           let next_row = curr_row in
           normalize_row_helper next_col next_row next_elt
    | _ -> failwith "impossible case"
  in
  let col, row = normalize_row_helper 1 1 (Doubly_linked.first_elt buf.text) in
  buf.col <- col;
  buf.row <- row


  (* Getters *)
let get_string (buf:t) : string=
  let concat accum (c, _) = accum^(Char.escaped c) in
  Doubly_linked.fold buf.text ~f:concat ~init:""

let get_char_at_cursor (buf:t) : char option =
  fst buf.cursor
  >>| fun c ->
  let c, _ = Doubly_linked.Elt.value c in
  c

let get_mark (buf:t) : mark =
  fst buf.mark
  >>| fun _ ->
  snd buf.mark

let get_height (buf:t) = buf.height

let get_width (buf:t) = buf.width

let get_row (buf:t) = buf.row

let get_col (buf:t) = buf.col

let get_top_line (buf:t) = buf.top_line

(* Setters *)
let set_mark (buf:t) =
  buf.mark <- buf.cursor;
  buf

let unset_mark (buf:t) =
  buf.mark <- None, -1;
  buf

let dec_col buf =
  buf.col <- buf.col - 1;
  if buf.col = 0 then
    begin
      correct_col buf;
      buf.row <- buf.row - 1
    end

let move_cursor_right (buf:t) =
  let move_right cur was_newline =
    buf.cursor <- (Doubly_linked.next buf.text cur, (snd buf.cursor)+1);
    buf.col <- buf.col + 1;
    if buf.col > buf.width || was_newline then
      begin
        buf.col <- 1;
        buf.row <- buf.row + 1
      end
  in
  let _ =
    match fst buf.cursor with
    | Some c ->
       let value, _ = Doubly_linked.Elt.value c in
       move_right c (value = '\n')
    | None -> ()
  in
  buf

let move_cursor_left (buf:t) =
  let move_left cur =
    buf.cursor <- (Doubly_linked.prev buf.text cur, (snd buf.cursor)-1);
    dec_col buf
  in
  let _ =
    match fst buf.cursor with
    | Some c ->
       if not (Doubly_linked.is_first buf.text c) then
         move_left c
    | None ->
       match Doubly_linked.last_elt buf.text with
       | Some last ->
          buf.cursor <- Some last, (snd buf.cursor)-1;
          dec_col buf
       | None -> ()
  in
  buf

let set_height (buf:t) (height:int) =
  buf.height <- height;
  buf

let set_width (buf:t) (width:int) =
  buf.width <- width;
  buf

let set_col (buf:t) (col:pos) =
  let col = max col 0 in
  let starting_row = buf.row in
  let rec go_to_col () =
    let starting_col = buf.col in
    let move, rev =
      if buf.col < col then
        move_cursor_right, move_cursor_left
      else
        move_cursor_left, move_cursor_right
    in
    move buf |> ignore;
    if buf.row <> starting_row then
      rev buf
    else
      if buf.col = starting_col || buf.col = col then
        buf
      else
        go_to_col ()
  in
  go_to_col ()

let move_cursor_down (buf:t) =
  let starting_row = buf.row in
  let starting_col = buf.col in
  let rec go_down_row buf =
    let last_col = buf.col in
    move_cursor_right buf |> ignore;
    if buf.col = last_col  || starting_row <> buf.row then
      ()
    else
      go_down_row buf
  in
  go_down_row buf;
  set_col buf starting_col

let move_cursor_up (buf:t) =
  let starting_row = buf.row in
  let starting_col = buf.col in
  let rec go_up_row buf =
    let last_col = buf.col in
    move_cursor_left buf |> ignore;
    if buf.col = last_col  || starting_row <> buf.row then
      ()
    else
      go_up_row buf
  in
  go_up_row buf;
  set_col buf starting_col

let set_row (buf:t) (row:pos) =
  let row = max row 0 in
  let starting_col = buf.col in
  let rec go_to_row () =
    let starting_row = buf.row in
    let move =
      if buf.row < row then
        move_cursor_down
      else
        move_cursor_up
    in
    move buf |> ignore;
    if buf.row = starting_row || buf.row = row then
      ()
    else
      go_to_row ()
  in
  go_to_row ();
  set_col buf starting_col

let move_cursor_to_end (buf:t) =
  buf.cursor <- (None, Doubly_linked.length buf.text);
  correct_row_and_col buf;
  let top_line = buf.row - buf.height in
  buf.top_line <- max top_line 0;
  buf

let move_cursor_to_beginning (buf:t) =
  buf.cursor <- (Doubly_linked.first_elt buf.text, 0);
  buf.col <- 1;
  buf.row <- 1;
  buf.top_line <- 0;
  buf

let set_top_line (buf:t) (line:int) =
  buf.top_line <- line;
  buf

let set_text (buf:t) (text:string) =
  Doubly_linked.clear buf.text;
  String.iter (fun c -> ignore(Doubly_linked.insert_last buf.text (c, []))) text;
  buf.cursor <- (None, 0);
  buf.mark <- None, -1;
  buf

(* Text operations *)
let insert_char_at_cursor (buf:t) (chr:char) =
  let elt =
    match fst buf.cursor with
    | Some c -> Doubly_linked.insert_before buf.text c (chr, [])
    | None ->  Doubly_linked.insert_last buf.text (chr, [])
  in
  buf.cursor <- Some elt, snd buf.cursor;
  move_cursor_right buf

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

(* File operations *)
let write (buf:t) =
  File.write_string buf.file (get_string buf);
  buf

let get_file (buf:t) = buf.file

(* Constructor *)
let make_from_file (file:File.t) (width:int) (height:int) : t =
  let text = Doubly_linked.create () in
  let start = (None, 0) in
  let buf =
    {text=text; cursor=start; mark=None, -1; height=width; width=height; top_line=0;
     col=1; row=1; file=file}
  in
  let string_to_insert = File.get_contents file in
  let buf = insert_text_at_cursor buf string_to_insert in
  move_cursor_to_beginning buf

let stylized_text_of_buffer (buf:t) =
  let stylized_text = Style.stylized_text_of_char_ll buf.text in
  Style.wrap_lines buf.width stylized_text

let yank_text_between_mark_and_cursor ?kill:(kill=true) (buf:t) =
  fst buf.mark
  >>= fun m_elt ->
  fst buf.cursor
  >>| fun c_elt ->
  let m_pos, c_pos = snd buf.mark, snd buf.cursor in
  let build_yank acc elt =
    let c, _ = Doubly_linked.Elt.value elt in
    if kill then
      begin
        Doubly_linked.remove buf.text elt
      end;
    acc ^ (String.make 1 c)
  in
  let result =
    if m_pos < c_pos then
      fold_between build_yank "" buf.text m_elt c_elt
    else
      fold_between build_yank "" buf.text c_elt m_elt
  in
  result, unset_mark buf
