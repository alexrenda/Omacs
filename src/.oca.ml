let register_callbacks (controller:Controller.t) : Controller.t =
  let open Key in
  let open Controller in
  let open Utils in
  let kill_buffer = ref None in

  let compose f1 f2 b =
    let b = f1 b in
    f2 b
  in
  let (||>) = compose in

  let wrap_bfun (callback:OBuffer.t -> OBuffer.t) (c:Controller.t) (b:OBuffer.t)
      : Controller.t * OBuffer.t =
    c, callback b
  in

  let save_func b = Printf.printf "Saved buffer"; OBuffer.write b in
  let close_func b = Terminal.close (); b in
  let beginning_of_line b = OBuffer.set_col b 1 in
  let end_of_line b = OBuffer.set_col b (OBuffer.get_width b) in

  let paste_region b =
    match !kill_buffer with
    | None -> b
    | Some str -> OBuffer.insert_text_at_cursor b str
  in

  let yank_region_wrapper func buf =
    match func buf with
    | Some (str, buf) -> kill_buffer := Some str;
                         buf
    | None -> buf
  in

  let yank = OBuffer.yank_text_between_mark_and_cursor ~kill:true
             |> yank_region_wrapper in
  let copy = OBuffer.yank_text_between_mark_and_cursor ~kill:false
            |> yank_region_wrapper in

  let get_kill_line_behavior buf =
    match OBuffer.get_char_at_cursor buf with
    | Some '\n' -> OBuffer.delete_char_at_cursor
    | _ -> beginning_of_line ||> OBuffer.set_mark ||> end_of_line ||> yank
  in

  let kill_line b = get_kill_line_behavior b b in

  let scroll_lines lines b =
    let start_row = OBuffer.get_row b in
    let b = OBuffer.set_row b (start_row + lines) in
    let start_view_row = OBuffer.get_top_line b in
    let b = OBuffer.set_top_line b (start_view_row + lines) in
    b
  in

  let scroll_half_page down b =
    let height = OBuffer.get_height b in
    let scroll_dist = if down then height / 2 else -height / 2 in
    let b = scroll_lines scroll_dist b in
    b
  in

  let scroll_half_page_down = scroll_half_page true in
  let scroll_half_page_up = scroll_half_page false in

  let center_screen b =
    let start_view_row = OBuffer.get_top_line b in
    let cursor_row = OBuffer.get_row b in
    let height = OBuffer.get_height b in
    let desired_row = start_view_row + height / 2 in
    let delta = desired_row - cursor_row in
    scroll_lines delta b
  in

  let function_map =
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
     ("C-space", OBuffer.set_mark);
     ("C-v", scroll_half_page_down);
     ("M-v", scroll_half_page_up);
     ("C-l", center_screen);
     ("C-x C-s", save_func);
     ("C-x C-c", close_func);
     ("C-y", paste_region);
     ("C-a", beginning_of_line);
     ("C-e", end_of_line);
     ("C-w", yank);
     ("M-w", copy);
     ("C-k", kill_line);
    ]
  in
  let all_functions = List.map (fun (a, b) -> a, (wrap_bfun b)) function_map in

  let accumulator controller (key, callback) =
    register_keypress_listener controller (key_of_string key) callback
  in

  let controller = List.fold_left accumulator controller all_functions in

  controller
;;
