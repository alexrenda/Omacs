exception EvalError

let devnull = open_out "/dev/null"
let formatter = Format.formatter_of_out_channel devnull
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

let eval_file file =
  Unix.dup2 devnull_fd Unix.stderr;
  ignore (Toploop.use_file formatter (File.get_path file));
  Unix.dup2 Unix.stderr devnull_fd;
  read_object "register_callbacks"

let register_api_function = write_object

let _ =
  Toploop.set_paths ();
  !Toploop.toplevel_startup_hook ();
  Toploop.initialize_toplevel_env ();
  let ocamlinit = File.file_of_string ".ocamlinit" in
  let file_text = File.get_contents ocamlinit in
  let lexed = Lexing.from_string file_text in
  let parsed = !Toploop.parse_toplevel_phrase lexed in
  ignore(Toploop.execute_phrase false formatter parsed);
  Topdirs.dir_directory ".";
  Topdirs.dir_directory "_build"
