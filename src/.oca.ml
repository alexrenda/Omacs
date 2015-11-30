let register_callbacks (controller:Controller.t) : Controller.t =
  let open Controller in
  let open Utils in
  let special_function_map =
    [(Backspace, OBuffer.delete_char_at_cursor);
     (Left, OBuffer.move_cursor_left);
     (Right, OBuffer.move_cursor_right);
     (Up, OBuffer.move_cursor_up);
     (Down, OBuffer.move_cursor_down);
     (End, OBuffer.move_cursor_to_end);
     (Home, OBuffer.move_cursor_to_beginning)]
  in
  let accumulator controller (key, callback) =
    let callback_wrapper c b = c, callback b in
    register_keypress_listener controller (Special key) callback_wrapper
  in

  let controller = List.fold_left accumulator controller special_function_map in

  let save_func c b = Printf.printf "Saved buffer%!";
                      c, OBuffer.write b in
  let controller = register_keypress_listener
                     controller (key_of_string "C-x C-s") save_func in

  let close_func c b = Terminal.close ();
                       c, b in
  let controller = register_keypress_listener
                     controller (key_of_string "C-x C-c") close_func in

  controller
;;
