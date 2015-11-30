open Key

let test_combos = ["{}", " {}", "{} "]

let basic_keys =
  [("x", Char 'x');
   ("tab", Char '\t');
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
let rec gen_modifier_combos acc key =
  let str, key = key in
  let acc = ("C-"^str, Mod(Control, key)) :: acc in
  let acc = ("M-"^str, Mod(Meta, key)) :: acc in
  acc

let rec assert_correctness = function
  | [] -> ()
  | (str, key)::t ->
     if Key.key_of_string str = key then
       assert_correctness t
     else
       failwith str

let _ =
  let all_modifiers = List.fold_left gen_modifier_combos [] basic_keys in
  let pair_with_all (str, key) =
    List.fold_left (fun acc (str', key') -> (str^str', Chain(key, key'))::acc)
                   [] all_modifiers
  in
  let all_mod_combos = List.fold_left (fun acc key -> (pair_with_all key) @ acc)
                                      [] all_modifiers in
  assert_correctness all_mod_combos
