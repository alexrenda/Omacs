open Core

type pos = char Doubly_linked.Elt.t option
type t = {text:char Doubly_linked.t; cursor:pos; mark:pos(*; file:File.t*)}

let make_from_file file = {text=Doubly_linked.create (); 
                           cursor=None; 
                           mark=None; 
                           file=file}

let get_text (buf:t) = 
    let concat accum c = accum^(Char.escaped c) in
    Doubly_linked.fold buf.text ~f:concat ~init:""
let get_cursor (buf:t) = buf.cursor
let get_mark (buf:t) = buf.mark
let get_width (buf:t) = buf.width
let get_height (buf:t) = buf.height
let get_view_row (buf:t) = buf.view_row

let set_width (buf:t) (width:int) =
  {buf with width=width}

let set_height (buf:t) (height:int) =
  {buf with height=height}

let set_view_row (buf:t) (view_row:int) =
  {buf with view_row=view_row}

let dist_since_newline (buf:t) =
  try
    String.rindex_from buf.text (buf.cursor - 1) '\n'
  with Not_found -> 0

let dist_to_newline (buf:t) =
  try
    String.index_from buf.text buf.cursor '\n'
  with Not_found -> String.length buf.text - buf.cursor

let get_col (buf:t) =
  dist_since_newline buf mod buf.width

let set_col (buf:t) (col:int) =
  let col = max col 0 in
  let curr_col = get_col buf in
  let to_col = buf.cursor - (curr_col - col) in
  {buf with cursor=to_col}

let get_row (buf:t) =
  let rec get_row_helper row idx =
    if idx >= buf.cursor then
      row
    else
      let dist = String.index_from buf.text idx '\n' in
      if dist > buf.width then
        get_row_helper (row + 1) (idx + buf.width)
      else
        get_row_helper (row + 1) (idx + dist + 1)
  in
  get_row_helper 0 0

let set_row (buf:t) (dest_row:int) =
  let dest_row = max dest_row 0 in
  let curr_col = get_col buf in
  let rec set_row_helper row idx =
    if row = dest_row then
      idx
    else
      let dist = String.index_from buf.text idx '\n' in
      if dist > buf.width then
        set_row_helper (row + 1) (idx + buf.width)
      else
        set_row_helper (row + 1) (idx + dist + 1)
  in
  let idx = set_row_helper 0 0 in
  let new_buf = {buf with cursor = idx} in
  set_col new_buf curr_col

let set_cursor (buf:t) (pos:pos) =
  {buf with cursor=pos}
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

