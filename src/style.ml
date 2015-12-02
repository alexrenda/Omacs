open LTerm_text

type t = Bold | Underline | Blink | Reverse
         | ForegroundColor of LTerm_style.color
         | BackgroundColor of LTerm_style.color
type stylized_text = LTerm_text.markup

let get_style_pair = function
  | Bold -> B_bold true, E_bold
  | Underline -> B_underline true, E_underline
  | Blink -> B_blink true, E_blink
  | Reverse -> B_reverse true, E_reverse
  | ForegroundColor c -> B_fg c, E_fg
  | BackgroundColor c -> B_bg c, E_bg

let stylized_text_of_char_ll lst : stylized_text =
  let build (char, styles) acc =
    let rec build_styles bacc eacc = function
      | [] -> bacc, eacc
      | s::t -> let b, e = get_style_pair s in
                let bacc = b :: bacc in
                let eacc = e :: eacc in
                build_styles bacc eacc t
    in
    let begin_styles, end_styles = build_styles [] [] styles in
    let second_half = (S (String.make 1 char)) :: end_styles in
    let all_rev = List.rev_append second_half begin_styles in
    List.rev all_rev :: acc
  in
  let all = Core.Doubly_linked.fold_right lst ~init:[] ~f:build in
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
