open Key

type hook =
  | FileOpen
  | FileSave
  | FileClose

type ('a, 'b) api_function = string*('a -> 'b)

type t = {keypress_listeners: (key, callback) Hashtbl.t;
          hook_listeners: (hook, callback) Hashtbl.t}

and result = t*OBuffer.t
and callback = t -> OBuffer.t -> result

let eval_file ?debug:(debug=false) (controller:t) (file:File.t) : t =
  Interpreter.eval_file debug file controller

let eval_file_and_output (controller:t) (file:File.t) =
  Utils.capture_output (fun () -> eval_file controller file) ()

let create () =
  let self = {keypress_listeners=Hashtbl.create 37;
              hook_listeners=Hashtbl.create 37} in
  let file = File.file_of_string ".oca.ml" in
  eval_file self file

let register_keypress_listener (controller:t) (key:key) (callback:callback) : t =
  Hashtbl.add controller.keypress_listeners key callback;
  controller

let register_hook_listener (controller:t) (hook:hook) (callback:callback) =
  Hashtbl.add controller.hook_listeners hook callback;
  controller

let keypress (controller:t) (key:key) (buffer:OBuffer.t) : result option =
  match key with
  | Char ch -> Some (controller, OBuffer.insert_char_at_cursor buffer ch)
  | _ ->
     try
       let callback = Hashtbl.find controller.keypress_listeners key in
       Some (callback controller buffer)
     with Not_found -> None

let keypress_and_output controller key buffer : (string*result) option =
  Utils.capture_output_option (fun () -> keypress controller key buffer) ()

let run_hook (controller:t) (hook:hook) (buffer:OBuffer.t) : result option =
  let rec run_all_hooks controller buffer = function
    | [] -> controller, buffer
    | callback::t -> let controller, buffer = callback controller buffer in
                     run_all_hooks controller buffer t
  in
  let all_hooks = Hashtbl.find_all controller.hook_listeners hook in
  Some (run_all_hooks controller buffer all_hooks)

let run_hook_and_output controller hook buffer =
  Utils.capture_output_option (fun () -> run_hook controller hook buffer) ()
