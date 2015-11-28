type modifier = Control | Meta | Super
type special = | End | Home | PageDown | PageUp
             | Up | Down | Left | Right
             | Delete | Insert | Escape
type key =
  | Char of char
  | Special of special
  | Mod of modifier * key
  | Chain of key * key

type hook =
  | FileOpen
  | FileSave
  | FileClose

type ('a, 'b) api_function = string*('a -> 'b)

type t = {keypress_listeners: (key, callback) Hashtbl.t;
          hook_listeners: (hook, callback) Hashtbl.t}

and result = t*OBuffer.t
and callback = t -> OBuffer.t -> result

let create () = {keypress_listeners=Hashtbl.create 37;
                 hook_listeners=Hashtbl.create 37}

let register_keypress_listener (controller:t) (key:key) (callback:callback) : t =
  Hashtbl.add controller.keypress_listeners key callback;
  controller

let register_hook_listener (controller:t) (hook:hook) (callback:callback) =
  Hashtbl.add controller.hook_listeners hook callback;
  controller

let keypress (controller:t) (key:key) (buffer:OBuffer.t) =
  try
    let callback = Hashtbl.find controller.keypress_listeners key in
    callback controller buffer
  with Not_found -> controller, buffer

let run_hook (controller:t) (hook:hook) (buffer:OBuffer.t) : result =
  let rec run_all_hooks controller buffer = function
    | [] -> controller, buffer
    | callback::t -> let controller, buffer = callback controller buffer in
                     run_all_hooks controller buffer t
  in
  let all_hooks = Hashtbl.find_all controller.hook_listeners hook in
  run_all_hooks controller buffer all_hooks

let eval_file (controller:t) (file:File.t) : t =
  Interpreter.eval_file file controller
