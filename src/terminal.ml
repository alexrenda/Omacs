open Curses

type t = int

let filename =
  let len = Array.length Sys.argv in
  try Sys.argv.(len - 1)
  with _ -> "*SCRATCH*"

let _ =
  let buf = OBuffer.make_from_file (File.file_of_string filename) in
  let window = initscr () in
  let _ = noecho () in
  let _ = (window, buf) in
  ignore (addstr (OBuffer.get_text buf));
  while true do
    let chr = getch () in
    ignore (addch chr)
  done

let create = failwith "TODO"
let show = failwith "TODO"
let open_file = failwith "TODO"
let close = failwith "TODO"
