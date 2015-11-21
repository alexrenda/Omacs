type key = string
type hook = string
type ('a, 'b) api_function = string*('a -> 'b)

(* TODO: make these more efficient data structures than assoc lists *)
type t = {keypress_listeners: (key*callback) list;
          hook_listeners: (hook*callback) list}

and result = t*OBuffer.t
and callback = t -> OBuffer.t -> result

let create () = {keypress_listeners=[]; hook_listeners=[]}

let register_keypress_event (controller:t) (key:key) (callback:callback) : t =
  {controller with keypress_listeners = (key, callback)::(controller.keypress_listeners)}

let register_hook (controller:t) (hook:hook) (callback:callback) =
  {controller with hook_listeners = (hook, callback)::(controller.hook_listeners)}

let keypress (controller:t) (key:key) (buffer:OBuffer.t) =
  let callback = List.assoc key controller.keypress_listeners in
  callback controller buffer

let run_hook (controller:t) (hook:hook) (buffer:OBuffer.t) : result =
  let callback = List.assoc hook controller.keypress_listeners in
  callback controller buffer

(* TODOL fix this w.r.t interpreter *)
let eval_file (controller:t) (file:File.t) : t =
  Interpreter.eval_file file controller
