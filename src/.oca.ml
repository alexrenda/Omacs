let register_callbacks (controller:Controller.t) : Controller.t =
  let open Key in
  let open Controller in
  let open Utils in
  let kill_buffer = ref None in

  let compose f1 f2 c b =
    let c, b = f1 c b in
    f2 c b
  in
  let (||>) = compose in
  let wrap_bfun (callback:OBuffer.t -> OBuffer.t) (c:Controller.t) (b:OBuffer.t)
      : Controller.t * OBuffer.t =
    c, callback b
  in

  let register c s f = register_keypress_listener c (key_of_string s) f in
  let save_func c b = Printf.printf "Saved buffer"; c, OBuffer.write b in
  let controller = register controller "C-x C-s" save_func in

  let close_func c b = Terminal.close (); c, b in
  let controller = register controller "C-x C-c" close_func in

  let beginning_of_line c b =
    let b = OBuffer.set_col b 0 in
    c, b
  in
  let end_of_line c b =
    let b = OBuffer.set_col b (OBuffer.get_width b) in
    c, b
  in
  let op_on_mark_region op c b =
    match OBuffer.get_mark b with
    | Some mark ->
       let curr_pos = OBuffer.get_cursor b in
       let text, buffer = op b curr_pos mark in
       kill_buffer := Some text;
       c, buffer
    | None ->
       c, b
  in
  let yank_region = op_on_mark_region OBuffer.yank_text_between_positions in
  let copy_region = op_on_mark_region OBuffer.copy_text_between_positions in
  let paste_region c b =
    match !kill_buffer with
    | None -> c, b
    | Some str ->
       let buf = OBuffer.insert_text_at_cursor b str in
       c, buf
  in

  let get_kill_line_behavior buf =
    match OBuffer.get_char_at_cursor buf with
    | '\n' -> wrap_bfun OBuffer.delete_char_at_cursor
    | _ -> beginning_of_line ||> (wrap_bfun OBuffer.set_mark) ||> end_of_line
           ||> yank_region
  in
  let kill_line c b =
    let f = get_kill_line_behavior b in
    f c b
  in
  let scroll_lines lines b =
    let start_view_row = OBuffer.get_view_row b in
    let b = OBuffer.set_view_row b (start_view_row + lines) in
    b
  in
  let scroll_half_page down c b =
    let height = OBuffer.get_height b in
    let scroll_dist = if down then height / 2 else -height / 2 in
    let b = scroll_lines scroll_dist b in
    c, b
  in
  let scroll_half_page_down = scroll_half_page true in
  let scroll_half_page_up = scroll_half_page false in

  let buffer_function_map =
    [("backspace", OBuffer.delete_char_at_cursor);
     ("left", OBuffer.move_cursor_left);
     ("C-f", OBuffer.move_cursor_left);
     ("right", OBuffer.move_cursor_right);
     ("C-b", OBuffer.move_cursor_right);
     ("up", OBuffer.move_cursor_up);
     ("C-p", OBuffer.move_cursor_up);
     ("down", OBuffer.move_cursor_down);
     ("C-n", OBuffer.move_cursor_up);
     ("end", OBuffer.move_cursor_to_end);
     ("M->", OBuffer.move_cursor_to_end);
     ("home", OBuffer.move_cursor_to_beginning);
     ("M-<", OBuffer.move_cursor_to_beginning);
     ("C-space", OBuffer.set_mark)
    ]
  in
  let other_function_map =
    [("C-x C-s", save_func);
     ("C-x C-c", close_func);
     ("C-a", beginning_of_line);
     ("C-e", end_of_line);
     ("C-w", yank_region);
     ("M-w", copy_region);
     ("C-y", paste_region);
     ("C-k", kill_line);
     ("C-v", scroll_half_page_down);
     ("M-v", scroll_half_page_up);
    ]
  in
  let callback_buffer_functions = List.map (fun (a, b) -> a, (wrap_bfun b))
                                           buffer_function_map in
  let all_functions = callback_buffer_functions @ other_function_map in

  let accumulator controller (key, callback) =
    register_keypress_listener controller (key_of_string key) callback
  in

  let controller = List.fold_left accumulator controller all_functions in

  controller
;;
