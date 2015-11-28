let contains str con =
  let re = Str.regexp_string con in
  try
    ignore (Str.search_forward re str 0);
    true
  with Not_found -> false

let concat_strings a b = a ^ " " ^ b
let add_ints a b = a - b
let alpha_to_unit a = ()
let unit_to_unit () = ()

let _ = Interpreter.register_api_function "concat_strs" concat_strings
let _ = Interpreter.register_api_function "add_ints" add_ints
let _ = Interpreter.register_api_function "alpha_to_unit" alpha_to_unit
let _ = Interpreter.register_api_function "unit_to_unit" unit_to_unit
let _ = Interpreter.register_api_function "unit_close_terminal" unit_to_unit

let filename =
  let len = Array.length Sys.argv in
  Sys.argv.(len - 1)

let controller = Controller.create ()
let f = File.file_of_string filename
let b = OBuffer.make_from_file f

open Unix
let read, write = pipe ()
let old_stdout = dup stdout
let old_stdout_channel = out_channel_of_descr old_stdout

let _ = dup2 write stdout

let c = Controller.eval_file controller f

open Utils
let keys_to_press = [key_of_string "C-x";
                    key_of_string "C-xC-c";
                    key_of_string "backspace"]

let rec press_keys = function
  | [] -> ()
  | key::t ->
     let _ = Controller.keypress c key b in
     press_keys t
let _ = press_keys keys_to_press

let _ = dup2 old_stdout stdout

let read_channel = in_channel_of_descr read


let passed =
  let ready, _, _ = Unix.select [read] [] [] 0.1 in
  if List.length ready = 0 then
    false
  else
    let line = input_line read_channel in
    contains line "passed"

let _ = if not passed then
          exit 1
        else
          ()
