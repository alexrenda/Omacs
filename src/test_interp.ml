let filename =
  let len = Array.length Sys.argv in
  Sys.argv.(len - 1)

let controller = Controller.create ()
let f = File.file_of_string filename
let c = Controller.eval_file controller f
let b = OBuffer.make_from_file f
let _ = Controller.keypress c "x" b
let _ = Printf.printf "we good\n"
