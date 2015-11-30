type modifier = Control | Meta
type special = | End | Home | PageDown | PageUp
             | Up | Down | Left | Right
             | Backspace | Delete | Insert | Escape
type key =
  | Char of char
  | Special of special
  | Mod of modifier * key
  | Chain of key * key

val key_of_string : string -> key
val string_of_key : key -> string
