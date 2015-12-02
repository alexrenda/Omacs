let _ = Sys.command "stty -iexten"

let () =
  try
    Terminal.main ()
  with _ -> ()

let _ = Sys.command "stty iexten"
