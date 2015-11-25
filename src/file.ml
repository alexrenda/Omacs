type t = string

let file_of_string (file:string) : t =
  file

let get_contents (file:t) : string =
  let rec get_all_lines acc stream =
    try
      let acc' = acc ^ (input_line stream) ^ "\n" in
      get_all_lines acc' stream
    with _ -> acc
  in
  let stream = open_in file in
  let contents = get_all_lines "" stream in
  close_in stream;
  contents

let get_name = Filename.basename
let get_path = Filename.dirname
let write_string (file:t) (str:string) : unit =
  let stream = open_out file in
  output_string stream str;
  close_out stream
