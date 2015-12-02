type t = Bold | Underline | Blink | Reverse
         | ForegroundColor of LTerm_style.color
         | BackgroundColor of LTerm_style.color
type stylized_text = LTerm_text.markup

val stylized_text_of_char_ll : (char*t list) Core.Doubly_linked.t -> stylized_text

val wrap_lines : int -> stylized_text -> (int list * stylized_text)
