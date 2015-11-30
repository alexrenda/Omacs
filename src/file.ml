type t = string

exception File_not_found

let file_of_string (file:string) : t =
  file

let get_contents (file:t) : string =
  if Sys.file_exists file then
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
  else
    raise File_not_found

let get_name = Filename.basename
let get_path f = f
let write_string (file:t) (str:string) : unit =
  let stream = open_out file in
  output_string stream str;
  close_out stream
