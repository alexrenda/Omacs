open OBuffer

let _ = print_endline "Output should be
-----

a
as
asd
asdf
asd
ad
a

-----"

let b = StringBuffer.make ()

let _ = print_endline (StringBuffer.get_text b)

let b = StringBuffer.insert_char b 'a'

let _ = print_endline (StringBuffer.get_text b)

let b = StringBuffer.insert_char b 's'

let _ = print_endline (StringBuffer.get_text b)

let b = StringBuffer.insert_char b 'd'

let _ = print_endline (StringBuffer.get_text b)

let b = StringBuffer.insert_char b 'f'

let _ = print_endline (StringBuffer.get_text b)

let b = StringBuffer.delete_char b

let _ = print_endline (StringBuffer.get_text b)

let b = StringBuffer.move_cursor_left b
let b = StringBuffer.delete_char b

let _ = print_endline (StringBuffer.get_text b)

let b = StringBuffer.delete_char b

let _ = print_endline (StringBuffer.get_text b)

let b = StringBuffer.move_cursor_right b
let b = StringBuffer.delete_char b

let _ = print_endline (StringBuffer.get_text b)
