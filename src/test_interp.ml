let concat_strings a b = a ^ " " ^ b
let add_ints a b = a - b
let alpha_to_unit a = ()
let unit_to_unit () = ()

let _ = Interpreter.register_api_function "concat_strs" concat_strings
let _ = Interpreter.register_api_function "add_ints" add_ints
let _ = Interpreter.register_api_function "alpha_to_unit" alpha_to_unit
let _ = Interpreter.register_api_function "unit_to_unit" unit_to_unit


let filename =
  let len = Array.length Sys.argv in
  Sys.argv.(len - 1)

let controller = Controller.create ()
let f = File.file_of_string filename
let c = Controller.eval_file controller f
let b = OBuffer.make_from_file f

let _ =
  try
    ignore (Controller.keypress c (Controller.Char 'x') b)
  with _ -> ()
let _ = Printf.printf "done\n"
