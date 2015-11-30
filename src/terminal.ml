(* Basic framework borrowed from lterm/examples/move.ml *)

open Lwt
open Lwt_react
open LTerm_geom
open LTerm_text
open LTerm_key

let return, (>>=) = Lwt.return, Lwt.(>>=)

let running = ref true
let key_to_print = ref None

let filename =
  let len = Array.length Sys.argv in
  try Sys.argv.(len - 1)
  with _ -> "*SCRATCH*"

let rec main_loop ui controller buf_ref last_key =
  LTerm_ui.wait ui >>=
    fun event ->
    let this_key =
      match event with
      | LTerm_event.Key key -> let keystr = LTerm_key.to_string_compact key in
                               Some (Utils.key_of_string keystr)
      | _ -> None
    in
    let run_keypress = function
      | Some key ->
         let controller, buffer = Controller.keypress controller
                                                      key !buf_ref in
         buf_ref := buffer;
         controller
      | _ -> controller
    in
    let next_key = match this_key, last_key with
      | (None, _) -> None
      | (Some key, None) -> Some key
      | (Some this_key, Some (Controller.Mod (m, k))) ->
         Some (Controller.Chain (Controller.Mod (m, k), this_key))
      | (Some key, Some _) -> Some key
    in
    key_to_print := next_key;
    let controller = run_keypress next_key in
    LTerm_ui.draw ui;
    if !running then
      main_loop ui controller buf_ref next_key
    else
      return ()

let draw_line_numbers size ui buf =
  let starting_line_number = OBuffer.get_view_row !buf in
  let last_line_number = starting_line_number + size.rows in
  let digits = 1 + int_of_float(log10(float_of_int last_line_number)) in
  let linum_size = {size with cols = digits + 1} in
  let linum_rect = {row1=0; col1=0; col2 = linum_size.cols;
                    row2 = linum_size.rows} in
  let text_rect = {row1=0;
                   col1=linum_size.cols;
                   col2 = size.cols;
                   row2 = size.rows} in
  let linum = LTerm_draw.sub ui linum_rect in
  let text = LTerm_draw.sub ui text_rect in
  let rec get_all_line_numbers st =
    if st > last_line_number then
      []
    else
      (string_of_int st) :: (get_all_line_numbers (st + 1))
  in
  let linum_str = String.concat "\n" (get_all_line_numbers 1) in
  LTerm_draw.draw_styled linum 0 0 (eval [B_fg LTerm_style.lblack;
                                          S linum_str;
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
  let f_str = Printf.sprintf "File: %s" filename in
  let key =
    match !key_to_print with
    | None -> ""
    | Some key -> Utils.string_of_key key
  in
  let k_str = Printf.sprintf "Key: %s" key in
  let status_width = status_size.cols in
  let status_str = Printf.sprintf "%-*s\n%-*s"
                                  status_width f_str
                                  status_width k_str in
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

  let text, text_rect = draw_line_numbers ui_size ui_ctx buf in
  let linum_size = text_rect.col1 in

  buf := OBuffer.set_width !buf (ui_rect.col2 - linum_size);

  let row = OBuffer.get_view_row !buf in
  let text_str = OBuffer.str_of_buffer !buf in
  (* A9B7C6 *)
  LTerm_draw.draw_styled text (-row) 0 (eval [B_fg LTerm_style.default;
                                              S text_str;
                                              E_fg]);
  LTerm_ui.set_cursor_position ui {row=OBuffer.get_row !buf - row;
                                   col=linum_size + OBuffer.get_col !buf}

let run () =
  Lazy.force LTerm.stdout
  >>= fun term ->
  let file = File.file_of_string filename in
  let buf = ref (OBuffer.make_from_file file 80 80) in
  let controller = Controller.create () in
  LTerm_ui.create term (fun matrix size -> draw matrix size buf)
  >>= fun ui ->
  LTerm_ui.set_cursor_visible ui true;
  Lwt.finalize (fun () -> main_loop ui controller buf None)
               (fun () -> LTerm_ui.quit ui)
let main () =
  Lwt_main.run (run ())

let close () =
  running := false

let do_nothing () = ()
