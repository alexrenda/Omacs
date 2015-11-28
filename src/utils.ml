open Controller

let modifier_regexp = Str.regexp "\\([CMS]\\)-"
let name_to_key_assoc_map =
  [("tab", Char '\t');
   ("backspace", Char '\b');
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
   ("delete", Special Delete);
   ("insert", Special Insert);
   ("escape", Special Escape);
  ]

let key_regexp =
  let all_keys = List.fold_left (fun acc (str, _) -> str::acc) ["[a-z]"]
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
        | "S-" -> Super
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
