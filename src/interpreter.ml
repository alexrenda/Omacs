exception EvalError

let devnull = open_out "/dev/null"
let formatter_stdout = Format.formatter_of_out_channel stdout
let formatter_stderr = Format.formatter_of_out_channel stderr
let formatter_devnull = Format.formatter_of_out_channel devnull
let devnull_fd = Unix.descr_of_out_channel devnull

let id_counter = ref 0
let create_type_for_var name =
  let open Types in
  let val_kind = Types.Val_reg in
  let val_loc = Location.none in
  let val_attributes = [] in

  let level = Btype.generic_level in

  let id = !id_counter in
  incr id_counter;
  let full = {desc = Tarrow ("",
                             {desc = Tvar (Some "a"); level; id},
                             {desc = Tvar (Some "b"); level; id},
                             Cok);
              level;
              id}
  in
  {Types.val_type=full; val_kind; val_loc; val_attributes}

let write_object name obj =
  let oldenv = !Toploop.toplevel_env in
  let t = create_type_for_var name in
  let newenv = Env.add_value (Ident.create name) t oldenv in
  Toploop.toplevel_env := newenv;
  Toploop.setvalue name (Obj.repr obj)

let read_object name =
  Obj.obj (Toploop.getvalue name)

let eval_file debug file =
  let path = File.get_path file in
  let output, success =
    Utils.capture_output ~stdout:false
                         (Toploop.use_file formatter_stderr) path in
  if success then
    read_object "register_callbacks"
  else
    failwith (Printf.sprintf "Could not eval file %s:\n%s" path output)

let register_api_function = write_object

let _ =
  Toploop.set_paths ();
  !Toploop.toplevel_startup_hook ();
  Toploop.initialize_toplevel_env ();
  Topdirs.dir_directory ".";
  Topdirs.dir_directory "_build";
