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
let b = OBuffer.make_from_file f 80 80
let str, controller = Utils.capture_output
                        (Controller.eval_file ~debug:false controller) f
let _ = Terminal.do_nothing ()

open Key
let keys_to_press = [key_of_string "C-x";
                    key_of_string "C-xC-c";
                    key_of_string "backspace"]

let rec press_keys str controller buffer = function
  | [] -> str, (controller, buffer)
  | key::t ->
     let s, (c, b) = Controller.keypress_and_output controller key buffer in
     let str = s ^ str in
     press_keys str controller buffer t

let str, (_, _) = press_keys str controller b keys_to_press


let passed = contains str "passed"
let _ = if not passed then
          exit 1
        else
          ()
