type t = Bold | Underline | Blink | Reverse
         | ForegroundColor of LTerm_style.color
         | BackgroundColor of LTerm_style.color
type stylized_text = LTerm_text.markup

val stylized_text_of_char_ll : ?highlight_region:(int*int) option
                               -> (char*t list ref) Core.Doubly_linked.t
                               -> stylized_text

val wrap_lines : int -> stylized_text -> (int list * stylized_text)

val string_of_stylized_text : stylized_text -> string
