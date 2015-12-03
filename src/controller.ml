open Key

type ('a, 'b) api_function = string*('a -> 'b)

type t = {keypress_listeners: (key, callback) Hashtbl.t}

and result = t*OBuffer.t
and callback = t -> OBuffer.t -> result

let (>>) f g x = g (f x)
let (&+) f g x = f x && g x

let eval_file ?debug:(debug=false) (controller:t) (file:File.t) : t =
  Interpreter.eval_file debug file controller

let eval_file_and_output (controller:t) (file:File.t) =
  Utils.capture_output (fun () -> eval_file controller file) ()

let create () =
  let self = {keypress_listeners=Hashtbl.create 37} in
  let file = File.file_of_string ".oca.ml" in
  let controller = eval_file self file in

  let ocamldir = File.file_of_string "~/.oca.ml.d" in
  let ocaml_files = File.get_files_in_directory ocamldir in
  let is_ocaml_file f = Utils.string_ends_with ".oca.ml" (File.get_name f) in
  let ocaml_files = List.filter ((File.is_directory >> (not))
                                 &+ is_ocaml_file)
                                ocaml_files in

  let rec eval_all controller = function
    | [] -> controller
    | f::t -> let controller = eval_file controller f in
              eval_all controller t
  in
  eval_all controller ocaml_files

let register_keypress_listener (controller:t) (key:key) (callback:callback) : t =
  Hashtbl.add controller.keypress_listeners key callback;
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
