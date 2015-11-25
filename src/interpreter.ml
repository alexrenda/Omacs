exception EvalError

let formatter = Format.formatter_of_out_channel (open_out "/dev/null")

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
  with
  |Typetexp.Error (loc, env, err) ->
    let f = Format.formatter_of_out_channel stdout in
    Typetexp.report_error env f err;
    print_newline ();
    raise EvalError
  | Symtable.Error e ->
     match e with
     | Symtable.Undefined_global s
     | Symtable.Unavailable_primitive s
     | Symtable.Wrong_vm s
     | Symtable.Uninitialized_global s -> Printf.printf "err: %s\n" s;
                                          failwith "asd"

let eval_file file =
  ignore (Toploop.use_file formatter (File.get_path file));
  read_object "register_callbacks"

let register_api_function = write_object

let _ =
  Toploop.set_paths ();
  !Toploop.toplevel_startup_hook ();
  Toploop.initialize_toplevel_env ();
  let ocamlinit = File.file_of_string ".ocamlinit" in
  let file_text = File.get_contents ocamlinit in
  eval file_text;
  Topdirs.dir_directory ".";
  Topdirs.dir_directory "_build"
