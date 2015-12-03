let (>>) f g x = g (f x)

module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
  val map : 'a t -> ('a -> 'b) -> 'b t
  val (>>|) : 'a t -> ('a -> 'b) -> 'b t
  end

let capture_output (f:'a->'b) (a:'a) : string*'b =
  let open Unix in
  let read, write = pipe () in
  let old_stdout = dup stdout in
  let _ = dup2 write stdout in

  let result = f a in
  print_newline ();
  flush Pervasives.stdout;

  let _ = dup2 old_stdout stdout in
  let read_channel = in_channel_of_descr read in
  let output = input_line read_channel in
  output, result

let capture_output_option (f: 'a -> 'b option) (a:'a) : (string*'b) option =
  let output, result = capture_output f a in
  match result with
  | Some result -> Some (output, result)
  | None -> None

module Option = struct
  type 'a t = 'a option
  let return a = Some a
  let bind a f =
    match a with
    | Some a -> f a
    | None -> None
  let (>>=) = bind

  let map a f = bind a (f >> return)
  let (>>|) = map
end

(* forked and improved from
 * https://github.com/diml/lambda-term/blob/master/src/lTerm_key.ml *)

let string_of_code keycode =
  let open LTerm_key in
  let open CamomileLibraryDyn.Camomile in
  match keycode with
  | Enter -> "return"
  | Escape -> "escape"
  | Tab -> "tab"
  | Up -> "up"
  | Down -> "down"
  | Left -> "left"
  | Right -> "right"
  | F1 -> "f1"
  | F2 -> "f2"
  | F3 -> "f3"
  | F4 -> "f4"
  | F5 -> "f5"
  | F6 -> "f6"
  | F7 -> "f7"
  | F8 -> "f8"
  | F9 -> "f9"
  | F10 -> "f10"
  | F11 -> "f11"
  | F12 -> "f12"
  | Next_page -> "pagedown"
  | Prev_page -> "pageup"
  | Home -> "home"
  | End -> "end"
  | Insert -> "insert"
  | Delete -> "delete"
  | Backspace -> "backspace"
  | LTerm_key.Char ch -> Printf.sprintf "Char 0x%02x" (UChar.code ch)

let to_string_compact (key:LTerm_key.t) =
  let open LTerm_key in
  let open CamomileLibraryDyn.Camomile in
  let buffer = Buffer.create 32 in
  if key.control then Buffer.add_string buffer "C-";
  if key.meta then Buffer.add_string buffer "M-";
  if key.shift then Buffer.add_string buffer "S-";
  (match key.code with
     | Char ch ->
         let code = UChar.code ch in
         if code <= 255 then
           match code with
           | 32 -> Buffer.add_string buffer "space"
           | ch when ch > 20 && ch < 127 ->
              Buffer.add_char buffer (char_of_int ch)
           | _ -> Printf.bprintf buffer "U+%02x" code
         else if code <= 0xffff then
           Printf.bprintf buffer "U+%04x" code
         else
           Printf.bprintf buffer "U+%06x" code
     | Next_page ->
         Buffer.add_string buffer "pageup"
     | Prev_page ->
         Buffer.add_string buffer "pagedown"
     | code ->
         Buffer.add_string buffer (String.lowercase (string_of_code code)));
  Buffer.contents buffer

let string_ends_with ending str =
  let end_len = String.length ending in
  let str_len = String.length str in
  if end_len > str_len then
    false
  else
    String.sub str (str_len - end_len) end_len = ending
