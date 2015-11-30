type pos = int
type t = {text:string; cursor:pos; mark:pos; file:File.t; width:int; height:int;
          view_row:int; length:int}

let make_from_file file width height =
  let text =
    try File.get_contents file
    with File.File_not_found -> ""
  in
  {text; cursor=0; mark=0; file; width; height; view_row=0;
   length=String.length text}

let get_text (buf:t) = buf.text
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
  {buf with cursor=min (buf.cursor + 1) buf.length}
let move_cursor_left (buf:t) =
  {buf with cursor=max (buf.cursor - 1) 0}

let move_cursor_up (buf:t) =
  let curr_col = get_col buf in
  let buf = set_col buf 0 in
  let buf = move_cursor_left buf in
  let last = set_col buf curr_col in
  last

let move_cursor_down (buf:t) =
  let curr_col = get_col buf in
  let buf = set_col buf buf.width in
  let buf = move_cursor_right buf in
  set_col buf curr_col

let move_cursor_to_beginning (buf:t) =
  {buf with cursor=0}
let move_cursor_to_end (buf:t) =
  {buf with cursor=String.length buf.text - 1}

let set_text (buf:t) (text:string) = {buf with text;length=String.length text}

let insert_char_at_cursor (buf:t) (chr:char) =
  let left = String.sub buf.text 0 buf.cursor in
  let right = String.sub buf.text buf.cursor (String.length buf.text - buf.cursor) in
  let new_text = left ^ (String.make 1 chr) ^ right in
  {buf with text=new_text; cursor=buf.cursor + 1; length=buf.length + 1}

let delete_char_at_cursor (buf:t) =
  try
    let left = String.sub buf.text 0 (buf.cursor - 1) in
    let right = String.sub buf.text buf.cursor (String.length buf.text - buf.cursor) in
    let new_text = left ^ right in
    {buf with text=new_text; cursor=buf.cursor - 1; length=buf.length - 1}
  with Invalid_argument _ -> buf

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


let str_of_buffer buf =
  (* http://rosettacode.org/wiki/Repeat_a_string *)
  let string_repeat s n =
    Array.fold_left (^) "" (Array.make n s)
  in
  let chars = string_repeat "[^\n]" buf.width in
  let full = "\\(" ^ chars ^ "\\)\\([^\n]\\)" in
  let re = Str.regexp full in
  let rec fix_all str =
    let replaced = Str.replace_first re "\\1\n\\2" str in
    if replaced = str then
      str
    else
      fix_all replaced
  in
  fix_all buf.text
