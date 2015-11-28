let modifier_regexp = Str.regexp "\\([CMS]\\)-"
let key_regexp = Str.regexp "\\(tab\\|backspace\\|return\\|space\\|[a-z]\\)"
let whitespace_regexp = Str.regexp "[ \t\n\r]"
let name_to_key_assoc_map =
  [("tab", '\t');("backspace", '\b'); ("return", '\n'); ("space", ' ')]

let remove_whitespace = Str.global_replace whitespace_regexp ""

let key_of_string str =
  let str = remove_whitespace str in
  let rec get_mod_key idx =
    if Str.string_match modifier_regexp str idx then
      let mod_key =
        match Str.matched_string str with
        | "C-" -> Controller.Control
        | "M-" -> Controller.Meta
        | "S-" -> Controller.Super
        | _ -> failwith "Exceptional case - regexp did not meet postcondition"
      in
      let rest, last_idx = get_mod_key (idx + 2) in
      Controller.Mod (mod_key, rest), last_idx
    else
      if Str.string_match key_regexp str idx then
        let matched = Str.matched_string str in
        let key =
          try
            List.assoc matched name_to_key_assoc_map
          with Not_found -> matched.[0]
        in
        Controller.Char key, idx + (String.length matched)
      else
        failwith ("Could not match character: " ^ str)
  in
  let rec chain_keys idx =
    if idx < String.length str then
      let key, idx = get_mod_key idx in
      match chain_keys idx with
      | None -> Some key
      | Some next_key -> Some (Controller.Chain (key, next_key))
    else
      None
  in
  match chain_keys 0 with
  | Some key -> key
  | None -> failwith ("Bad key expression: " ^ str)
