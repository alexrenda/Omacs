open Curses

type t = int

let _ =
  let buf = Obuffer.make_from_file (File.file_of_string "*SCRATCH*") in
  let window = initscr () in
  let _ = noecho () in
  let _ = (window, buf) in
  while true do
    let chr = getch () in
    ignore (addch chr)
  done

let create = failwith "TODO"
let show = failwith "TODO"
let open_file = failwith "TODO"
let close = failwith "TODO"
