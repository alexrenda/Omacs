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
