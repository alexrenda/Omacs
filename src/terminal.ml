(* Basic framework borrowed from lterm/examples/move.ml *)

open Lwt
open Lwt_react
open LTerm_geom
open LTerm_text
open LTerm_key

let return, (>>=) = Lwt.return, Lwt.(>>=)

let running = ref true
let key_to_print = ref None
let status_str = ref ""

let filename =
  let len = Array.length Sys.argv in
  try Sys.argv.(len - 1)
  with _ -> "*SCRATCH*"

let rec main_loop ui controller buf_ref prefix_key =
  LTerm_ui.wait ui
  >>= fun event ->
  let this_key =
    match event with
    | LTerm_event.Key key -> let keystr = Key.lterm_key_to_string key in
                             let key = Key.key_of_string keystr in
                             Some key
    | _ -> None
  in
  let run_keypress = function
    | Some key ->
       (match Controller.keypress_and_output controller key !buf_ref with
        | Some (str, (controller, buffer)) ->
           buf_ref := buffer;
           status_str := str;
           controller
        | None -> controller)
    | _ -> controller
  in
  let action_key = match this_key, prefix_key with
    | (None, _) -> None
    | (Some key, None) -> this_key
    | (Some this_key, Some (Key.Mod (m, k))) ->
       Some (Key.Chain (Key.Mod (m, k), this_key))
    | (Some key, Some _) -> this_key
  in
  key_to_print := action_key;
  let controller = run_keypress action_key in
  let next_prefix_key =
    let open Key in
    match action_key with
    | Some (Mod (Control, (Char 'x'))) ->
       action_key
    | _ -> None
  in
  LTerm_ui.draw ui;
  if !running then
    main_loop ui controller buf_ref next_prefix_key
  else
    return ()

let draw_line_numbers size ui line_nums top_line =
  let line_nums = List.map string_of_int line_nums in
  let digits =
    let last_line = top_line + size.rows in
    let last_line_number =
      try
        List.nth line_nums (last_line - 1)
      with _ -> string_of_int (List.length line_nums)
    in
    String.length last_line_number
  in
  let linum_size = {size with cols = digits + 1} in
  let linum_rect = {row1=0; col1=0; col2 = linum_size.cols;
                    row2 = linum_size.rows} in
  let text_rect = {row1=0;
                   col1=linum_size.cols;
                   col2 = size.cols;
                   row2 = size.rows} in
  let linum = LTerm_draw.sub ui linum_rect in
  let text = LTerm_draw.sub ui text_rect in
  let rec get_linum_str last_num lst idx str =
    if idx = size.rows then
      str
    else
      match lst with
      | [] -> str
      | h::t when h = last_num ->
         let acc = Printf.sprintf "%s\n" str in
         get_linum_str h t (idx+1) acc
      | h::t ->
         let acc = Printf.sprintf "%s%s\n" str h in
         get_linum_str h t (idx+1) acc
  in
  let rec remove_n_from_list n = function
    | lst when n <= 0 -> lst
    | [] -> []
    | h::t -> remove_n_from_list (n-1) t
  in
  let linum_text = get_linum_str "" (remove_n_from_list (top_line - 1) line_nums)
                                 0 "" in
  LTerm_draw.draw_styled linum 0 0 (eval [B_fg LTerm_style.lblack;
                                          S linum_text;
                                          E_fg]);
  text, text_rect

let draw_status size ui buf =
  let status_size = {size with rows = 2} in
  let status_rect = {row1=size.rows - status_size.rows; col1=0; col2 = size.cols;
                     row2 = size.rows} in
  let rest_rect = {row1=0;
                   col1=0;
                   col2 = size.cols;
                   row2 = status_rect.row1} in
  let status = LTerm_draw.sub ui status_rect in
  let rest = LTerm_draw.sub ui rest_rect in
  let file = OBuffer.get_file buf in
  let filename = File.get_name file in
  let top_line = Printf.sprintf "File: %s" filename in
  let key =
    match !key_to_print with
    | None -> ""
    | Some key -> Key.string_of_key key
  in
  let key_str = Printf.sprintf "  %s" key in
  let room_for_status = status_size.cols - 8 - (String.length key_str) in
  let status_str = Printf.sprintf "Status: %-.*s" room_for_status !status_str in
  let bottom_line = Printf.sprintf "%s%s" status_str key_str in
  let status_width = status_size.cols in
  let status_str = Printf.sprintf "%-*s\n%-*s"
                                  status_width top_line
                                  status_width bottom_line in
  LTerm_draw.draw_styled status 0 0 (eval [B_fg LTerm_style.lwhite;
                                           S status_str;
                                           E_fg]);
  rest, rest_rect

let draw ui matrix buf =
  let full_size = LTerm_ui.size ui in
  let ctx = LTerm_draw.context matrix full_size in
  let ui_ctx, ui_rect = draw_status full_size ctx !buf in
  let ui_size = {full_size with rows = ui_rect.row2-ui_rect.row1} in
  LTerm_draw.clear ui_ctx;

  let line_nums, buffer_text = OBuffer.stylized_text_of_buffer !buf in
  let top_line = OBuffer.get_top_line !buf in
  let text, text_rect = draw_line_numbers ui_size ui_ctx line_nums top_line  in
  let linum_size = text_rect.col1 in

  buf := OBuffer.set_width !buf (text_rect.col2 - text_rect.col1);
  buf := OBuffer.set_height !buf (text_rect.row2 - text_rect.row1);

  let top_line = OBuffer.get_top_line !buf in
  let buffer_text = (B_fg LTerm_style.lwhite)::buffer_text in

  LTerm_draw.draw_styled text (-top_line + 1) 0 (eval buffer_text);
  LTerm_ui.set_cursor_position ui {row=OBuffer.get_row !buf - top_line;
                                   col=linum_size + OBuffer.get_col !buf - 1}

let run () =
  Lazy.force LTerm.stdout
  >>= fun term ->
  let file = File.file_of_string filename in
  let buf = ref (OBuffer.make_from_file file 80 80) in
  let controller = Controller.create () in
  LTerm_ui.create term (fun matrix size -> draw matrix size buf;
                                           draw matrix size buf)
  >>= fun ui ->
  LTerm_ui.set_cursor_visible ui true;
  LTerm_ui.draw ui;
  Lwt.finalize (fun () -> main_loop ui controller buf None)
               (fun () -> LTerm_ui.quit ui)
let main () =
  try
    Lwt_main.run (run ())
  with Failure f -> Printf.printf "Failed to run terminal:\n%s\n" f

let close () =
  running := false

let do_nothing () = ()
