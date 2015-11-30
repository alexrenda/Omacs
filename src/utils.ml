let do_nothing () = ()

let capture_output (f:'a->'b) (a:'a) : string*'b =
  let open Unix in
  let read, write = pipe () in
  let old_stdout = dup stdout in
  let _ = dup2 write stdout in

  let result = f a in
  print_newline ();
  flush Pervasives.stdout;

  let _ = dup2 old_stdout stdout in
  let read_channel = in_channel_of_descr read in
  let output = input_line read_channel in
  output, result
