type modifier = Control | Meta | Super
type key =
  | Char of char
  | Mod of modifier * key
  | Chain of key * key

type hook = FileOpen | FileClose | FileSave

type ('a, 'b) api_function = string*('a -> 'b)

(* TODO: make these more efficient data structures than assoc lists *)
type t = {keypress_listeners: (key*callback) list;
          hook_listeners: (hook*callback) list}

and result = t*OBuffer.t
and callback = t -> OBuffer.t -> result

let create () = {keypress_listeners=[]; hook_listeners=[]}

let register_keypress_listener (controller:t) (key:key) (callback:callback) : t =
  {controller with keypress_listeners = (key, callback)::(controller.keypress_listeners)}

let register_hook_listener (controller:t) (hook:hook) (callback:callback) =
  {controller with hook_listeners = (hook, callback)::(controller.hook_listeners)}

let keypress (controller:t) (key:key) (buffer:OBuffer.t) =
  try
    let callback = List.assoc key controller.keypress_listeners in
    callback controller buffer
  with Not_found -> controller, buffer

let run_hook (controller:t) (hook:hook) (buffer:OBuffer.t) : result =
  try
    let callback = List.assoc hook controller.hook_listeners in
    callback controller buffer
  with Not_found -> controller, buffer

let eval_file (controller:t) (file:File.t) : t =
  Interpreter.eval_file file controller
