open Utils
open File
module Doubly_linked = Core.Doubly_linked

type pos = int
type mark = pos option
type char_rep = char * Style.t list ref
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

let correct_top_line buf : unit =
  if buf.row < buf.top_line then
    buf.top_line <- buf.row
  else if buf.row >= buf.top_line + buf.height then
    buf.top_line <- buf.row - buf.height + 1

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
  let dist =
    match fst buf.cursor with
    | Some elt -> normalize_col_helper 0 (Doubly_linked.prev buf.text elt)
    | None ->
       let last = Doubly_linked.last_elt buf.text in
       normalize_col_helper 0 last
  in
  buf.col <- 1 + (dist mod buf.width)

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
  buf.row <- row;
  correct_top_line buf

(* Getters *)
let get_string (buf:t) : string=
  let concat accum (c, _) = accum^(String.make 1 c) in
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
      buf.row <- buf.row - 1;
      correct_top_line buf
    end

let move_cursor_right (buf:t) =
  let move_right cur was_newline =
    buf.cursor <- (Doubly_linked.next buf.text cur, (snd buf.cursor)+1);
    buf.col <- buf.col + 1;
    if buf.col > buf.width || was_newline then
      begin
        buf.col <- 1;
        buf.row <- buf.row + 1;
        correct_top_line buf
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
  buf

let move_cursor_to_beginning (buf:t) =
  buf.cursor <- (Doubly_linked.first_elt buf.text, 0);
  buf.col <- 1;
  buf.row <- 1;
  buf.top_line <- 1;
  buf

let set_top_line (buf:t) (line:int) =
  let line = max 1 line in
  let line = min buf.row line in
  buf.top_line <- line;
  buf

let set_text (buf:t) (text:string) =
  Doubly_linked.clear buf.text;
  String.iter (fun c -> ignore(Doubly_linked.insert_last buf.text (c, ref []))) text;
  buf.cursor <- (None, 0);
  buf.mark <- None, -1;
  buf

(* Text operations *)
let insert_char_at_cursor (buf:t) (chr:char) =
  let elt =
    match fst buf.cursor with
    | Some c -> Doubly_linked.insert_before buf.text c (chr, ref [])
    | None ->  Doubly_linked.insert_last buf.text (chr, ref [])
  in
  if snd buf.mark >= snd buf.cursor then
    begin
      buf.mark <- fst buf.mark, (snd buf.mark - 1)
    end;
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
     if snd buf.mark > snd buf.cursor then
       begin
         buf.mark <- fst buf.mark, (snd buf.mark - 1)
       end
     else if snd buf.mark = snd buf.cursor then
       begin
         unset_mark buf |> ignore
       end;
     buf.cursor <- (Doubly_linked.next buf.text c, snd buf.cursor);
     Doubly_linked.remove buf.text c;
     buf
  | None -> buf

let set_text_style (buf:t) start finish style =
  let rec set_text_style_helper idx = function
    | Some elt ->
       if idx > finish then
         buf
       else if idx >= start then
         let _, prev_style = Doubly_linked.Elt.value elt in
         prev_style := style;
         let next = Doubly_linked.next buf.text elt in
         set_text_style_helper (idx + 1) next
       else
         let next = Doubly_linked.next buf.text elt in
         set_text_style_helper (idx + 1) next
    | None -> buf
  in
  set_text_style_helper 0 (Doubly_linked.first_elt buf.text)

let delete_char_before_cursor (buf:t) =
  if snd buf.cursor <> 0 then
    let buf = move_cursor_left buf in
    delete_char_at_cursor buf
  else
    buf

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
    {text=text; cursor=start; mark=None, -1; height=width; width=height;
     top_line=0; col=1; row=1; file=file}
  in
  let string_to_insert =
    try
      File.get_contents file
    with File_not_found -> ""
  in
  let buf = insert_text_at_cursor buf string_to_insert in
  move_cursor_to_beginning buf

let stylized_text_of_buffer (buf:t) =
  let _, cursor_pos = buf.cursor in
  let highlight_region =
    match buf.mark with
    | _, mark_pos when mark_pos >= 0->
       let start = min mark_pos cursor_pos in
       let finish = max mark_pos cursor_pos in
       Some (start, finish)
    | _, _ -> None
  in
  let stylized_text = Style.stylized_text_of_char_ll ~highlight_region buf.text in
  Style.wrap_lines buf.width stylized_text

let rec yank_text_between_mark_and_cursor ?kill:(kill=true) (buf:t)
        : (string*t) option =
  let m_pos, c_pos = snd buf.mark, snd buf.cursor in
  let mark_before_cursor = m_pos < c_pos in
  let movement =
    match kill, mark_before_cursor with
    | (true, true) -> delete_char_before_cursor
    | (false, true) -> move_cursor_left
    | (true, false) -> delete_char_at_cursor
    | (false, false) -> move_cursor_right
  in
  if m_pos = c_pos then
    Some ("", unset_mark buf)
  else if m_pos < 0 then
    None
  else
    let mark_before prev =
      let v, _ = Doubly_linked.Elt.value prev in
      let s = String.make 1 v in
      let buf = movement buf in
      s, buf
    in
    let mark_after c_elt =
      let v, _ = Doubly_linked.Elt.value c_elt in
      let s = String.make 1 v in
      let buf = movement buf in
      s, buf
    in
    let s, buf =
      match (fst buf.mark, fst buf.cursor) with
      | (None, Some c_elt) ->
         mark_after c_elt
      | (Some _, None) ->
         let prev_elt = match Doubly_linked.last_elt buf.text with
           | Some e -> e
           | None -> Printf.eprintf "err1\n";
                     failwith "exceptional"
         in
         mark_before prev_elt
      | (Some _, Some c_elt) ->
         if mark_before_cursor then
           let prev_elt = match Doubly_linked.prev buf.text c_elt with
             | Some e -> e
             | None -> Printf.eprintf "err2\n";
                       failwith "exceptional"
           in
           mark_before prev_elt
         else
           mark_after c_elt
      | _ -> Printf.eprintf "err3\n";
             failwith "exceptional"
    in
    let rest, buf =
      match yank_text_between_mark_and_cursor ~kill buf with
      | Some (rest, buf) -> rest, buf
      | None -> "", buf
    in
    if mark_before_cursor then
      Some (rest^s, buf)
    else
      Some (s^rest, buf)
