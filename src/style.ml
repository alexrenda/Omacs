open LTerm_text
open LTerm_style

type t = Bold | Underline | Blink | Reverse
         | ForegroundColor of color
         | BackgroundColor of color
type stylized_text = markup

let (>>=) = Utils.Option.bind

let get_style_pair = function
  | Bold -> B_bold true, E_bold
  | Underline -> B_underline true, E_underline
  | Blink -> B_blink true, E_blink
  | Reverse -> B_reverse true, E_reverse
  | ForegroundColor c -> B_fg c, E_fg
  | BackgroundColor c -> B_bg c, E_bg

let highlight_background_start = B_bg (rgb 76 75 116)
let highlight_background_end = E_bg

let stylized_text_of_char_ll ?highlight_region:(highlight_region=None) lst
    : stylized_text =
  let highlight_region =
    highlight_region
    >>= fun (s, e) ->
    if e > s then Some (s, e)
    else None
  in
  let build (char, styles) (pos, acc) =
    let styles = !styles in
    let rec build_styles bacc eacc = function
      | [] -> bacc, eacc
      | s::t -> let b, e = get_style_pair s in
                let bacc = b :: bacc in
                let eacc = e :: eacc in
                build_styles bacc eacc t
    in
    let begin_styles, end_styles = build_styles [] [] styles in
    let end_styles = (S (String.make 1 char)) :: end_styles in
    let begin_styles, end_styles =
      match highlight_region with
      | Some (start, finish) when start = pos ->
         (highlight_background_start::begin_styles), end_styles
      | Some (start, finish) when finish = pos ->
         begin_styles, (highlight_background_end::end_styles)
      | _ -> begin_styles, end_styles
    in
    let all_rev = List.rev_append end_styles begin_styles in
    (pos - 1), List.rev all_rev :: acc
  in
  let len = Core.Doubly_linked.length lst  - 1in
  let _, all = Core.Doubly_linked.fold_right lst ~init:(len, []) ~f:build in
  List.concat all

let wrap_lines_acc width (rev_lines_to_print, curr_row, curr_col, rev_stylized_str)
                   item =
  match item with
  | S s -> if s = "\n" then
             let next_row = curr_row + 1 in
             let next_col = 1 in
             let rev_lines_to_print = next_row :: rev_lines_to_print in
             let rev_stylized_str = item :: rev_stylized_str in
             (rev_lines_to_print, next_row, next_col, rev_stylized_str)
           else
             let next_col = curr_col + 1 in
             if next_col > width then
               let next_col = 1 in
               let rev_lines_to_print = curr_row :: rev_lines_to_print in
               let rev_stylized_str = S "\n" :: item :: rev_stylized_str in
               (rev_lines_to_print, curr_row, next_col, rev_stylized_str)
             else
               let rev_stylized_str = item :: rev_stylized_str in
               (rev_lines_to_print, curr_row, next_col, rev_stylized_str)
  | _ -> (rev_lines_to_print, curr_row, curr_col, item::rev_stylized_str)

let wrap_lines width stylized_text =
  let rev_lines_to_print, _, _, rev_stylized_str =
    List.fold_left (wrap_lines_acc width) ([1], 1, 1, []) stylized_text in
  List.rev rev_lines_to_print, List.rev rev_stylized_str

let rec string_of_stylized_text = function
  | [] -> ""
  | h::t ->
     let this_text =
       match h with
       | S s -> s
       | R r -> ""
       | B_bold _ -> "<bold>"
       | E_bold -> "</bold>"
       | B_underline _ -> "<underline>"
       | E_underline -> "</underline>"
       | B_blink _ -> "<blink>"
       | E_blink -> "</blink>"
       | B_reverse _ -> "<reverse>"
       | E_reverse -> "</reverse>"
       | B_fg (RGB (r, g, b)) -> Printf.sprintf "<fg: %d %d %d>" r g b
       | B_fg Default -> Printf.sprintf "<fg: default>"
       | B_fg (Index idx) -> Printf.sprintf "<fg: %d>" idx
       | E_fg -> "</fg>"
       | B_bg (RGB (r, g, b)) -> Printf.sprintf "<bg: %d %d %d>" r g b
       | B_bg Default -> Printf.sprintf "<bg: default>"
       | B_bg (Index idx) -> Printf.sprintf "<bg: %d>" idx
       | E_bg -> "</bg>"
     in
     this_text ^ (string_of_stylized_text t)
