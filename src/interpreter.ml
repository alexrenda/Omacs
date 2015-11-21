exception EvalError

let write_object name obj =
  Toploop.setvalue name (Obj.repr obj)

let read_object name =
  Obj.obj (Toploop.getvalue name)

(* TODO: CITE THIS *)
let eval text =
  try
    let lexed = Lexing.from_string text in
    let parsed = !Toploop.parse_toplevel_phrase lexed in
    ignore(Toploop.execute_phrase false Format.std_formatter parsed)
  with _ -> raise EvalError

let eval_file file controller =
  let file_text = File.get_contents file in
  eval file_text;
  read_object "register_callbacks"

let register_api_function = write_object
