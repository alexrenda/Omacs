type modifier = Control | Meta
type special = | End | Home | PageDown | PageUp
             | Up | Down | Left | Right
             | Backspace | Delete | Insert | Escape
type key =
  | Char of char
  | Special of special
  | Mod of modifier * key
  | Chain of key * key

let modifier_regexp = Str.regexp "\\([CM]\\)-"
let name_to_key_assoc_map =
  [("tab", Char '\t');
   ("return", Char '\n');
   ("space", Char ' ');
   ("end", Special End);
   ("home", Special Home);
   ("pagedown", Special PageDown);
   ("pageup", Special PageUp);
   ("up", Special Up);
   ("down", Special Down);
   ("left", Special Left);
   ("right", Special Right);
   ("backspace", Special Backspace);
   ("delete", Special Delete);
   ("insert", Special Insert);
   ("escape", Special Escape);
  ]
let key_to_name_assoc_map =
  let names, keys = List.split name_to_key_assoc_map in
  List.combine keys names

let key_regexp =
  let all_keys = List.fold_left (fun acc (str, _) -> str::acc) ["[\x00-\x7f]"]
                                name_to_key_assoc_map in
  let group_statement = String.concat "\\|" all_keys in
  Str.regexp ("\\(" ^ group_statement ^ "\\)")

let whitespace_regexp = Str.regexp "[ \t\n\r]"
let remove_whitespace = Str.global_replace whitespace_regexp ""

let key_of_string str =
  let str = remove_whitespace str in
  let rec get_mod_key idx =
    if Str.string_match modifier_regexp str idx then
      let mod_key =
        match Str.matched_string str with
        | "C-" -> Control
        | "M-" -> Meta
        | _ -> failwith "Exceptional case - regexp did not meet postcondition"
      in
      let rest, last_idx = get_mod_key (idx + 2) in
      Mod (mod_key, rest), last_idx
    else
      if Str.string_match key_regexp str idx then
        let matched = Str.matched_string str in
        let key =
          try
            List.assoc matched name_to_key_assoc_map
          with Not_found -> Char matched.[0]
        in
        key, idx + (String.length matched)
      else
        failwith ("Could not match character: " ^ str)
  in
  let rec chain_keys idx =
    if idx < String.length str then
      let key, idx = get_mod_key idx in
      match chain_keys idx with
      | None -> Some key
      | Some next_key -> Some (Chain (key, next_key))
    else
      None
  in
  match chain_keys 0 with
  | Some key -> key
  | None -> failwith ("Bad key expression: " ^ str)


let rec string_of_key = function
  | Mod (Control, k) -> "C-" ^ (string_of_key k)
  | Mod (Meta, k) -> "M-" ^ (string_of_key k)
  | Chain (k1, k2) -> (string_of_key k1) ^ " " ^ (string_of_key k2)
  | Char '\t' -> "tab"
  | Char '\n' -> "return"
  | Char ' ' -> "space"
  | Char c -> Char.escaped c
  | Special spec -> List.assoc (Special spec) key_to_name_assoc_map



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

let lterm_key_to_string (key:LTerm_key.t) =
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
         Buffer.add_string buffer (String.lowercase_ascii (string_of_code code)));
  Buffer.contents buffer
