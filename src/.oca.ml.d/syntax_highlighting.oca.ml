let zabb = 1;;

let register_callbacks (controller:Controller.t) : Controller.t =
  let open Key in
  let highlight_key = key_of_string "C-s" in
  let style = [Style.ForegroundColor (LTerm_style.rgb 255 0 0)] in
  let callback c b =
    let text = OBuffer.get_string b in
    let to_match, len =
      let to_match' = Terminal.minibuffer "Highlight: " in
      Str.regexp to_match', String.length to_match'
    in
    let search = Str.search_forward to_match text in
    let rec syntax_highlight_helper idx =
      try
        let idx = search idx in
        OBuffer.set_text_style b idx (idx + len - 1) style |> ignore;
        syntax_highlight_helper (idx + 1)
      with Not_found -> c, b
    in
    syntax_highlight_helper 0
  in

  let controller = Controller.register_keypress_listener
                     controller highlight_key callback in
  controller
;;
