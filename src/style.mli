type t = Bold | Underline | Blink | Reverse
         | ForegroundColor of LTerm_style.color
         | BackgroundColor of LTerm_style.color
type stylized_text = LTerm_text.markup

(* stylized_text_of_char_ll ~region ll
 * returns a list of markup items where each instance of Style.t has
 * been replaced with the proper markup tags. If highlight_region is
 * specified, then that region will be highlighted *)
val stylized_text_of_char_ll : ?highlight_region:(int*int) option
                               -> (char*t list ref) Core.Doubly_linked.t
                               -> stylized_text

(* wrap_lines width text returns (r, c) where (r, c) are as defined by *)
(* OBuffer.stylized_text_of_buffer *)
val wrap_lines : int -> stylized_text -> (int list * stylized_text)

(* get the string contained in a stylized_text instance, ignoring all *)
(* markup *)
val string_of_stylized_text : stylized_text -> string
