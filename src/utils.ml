let (>>) f g x = g (f x)

module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
  val map : 'a t -> ('a -> 'b) -> 'b t
  val (>>|) : 'a t -> ('a -> 'b) -> 'b t
  end

let str_of_fd fd =
  match Unix.select [fd] [] [] 0. with
  | [fd], [], [] ->
     let in_ch = Unix.in_channel_of_descr fd in
     let len = 4096 in
     let bytes = Bytes.create len in
     let len = input in_ch bytes 0 len in
     Bytes.sub_string bytes 0 len
  | _ -> ""

let get_devnull () =
  Unix.descr_of_out_channel (open_out "/dev/null")

let ignore_output (f:'a->'b) (a:'a) : 'b =
  let oldstdout = Unix.dup Unix.stdout in
  let newstdout = get_devnull () in
  let oldstderr = Unix.dup Unix.stderr in
  let newstderr = get_devnull () in
  Unix.dup2 newstderr Unix.stderr;
  Unix.dup2 newstdout Unix.stdout;
  let result = f a in
  Unix.dup2 oldstderr Unix.stderr;
  Unix.dup2 oldstdout Unix.stdout;
  result

let capture_output ?stdout:(cap_stdout=true)
                   ?stderr:(cap_stderr=true)
                   (f: 'a->'b) (a:'a) : string*'b =
  let oldstdout = Unix.dup Unix.stdout in
  let stdout_in, newstdout = Unix.pipe () in
  let oldstderr = Unix.dup Unix.stderr in
  let stderr_in, newstderr = Unix.pipe () in
  Unix.dup2 newstderr Unix.stderr;
  Unix.dup2 newstdout Unix.stdout;
  let result = f a in
  Unix.dup2 oldstderr Unix.stderr;
  Unix.dup2 oldstdout Unix.stdout;
  let stdout_str = str_of_fd stdout_in in
  let stderr_str = str_of_fd stderr_in in
  let str_result = match (cap_stdout, cap_stderr) with
    | true, true -> stdout_str ^ stderr_str
    | true, false -> stdout_str
    | false, true -> stderr_str
    | false, false -> ""
  in
  str_result, result

let capture_output_option (f: 'a -> 'b option) (a:'a) : (string*'b) option =
  let output, result = capture_output f a in
  match result with
  | Some result -> Some (output, result)
  | None -> None

module Option = struct
  type 'a t = 'a option
  let return a = Some a
  let bind a f =
    match a with
    | Some a -> f a
    | None -> None
  let (>>=) = bind

  let map a f = bind a (f >> return)
  let (>>|) = map
end

let string_ends_with ending str =
  let end_len = String.length ending in
  let str_len = String.length str in
  if end_len > str_len then
    false
  else
    String.sub str (str_len - end_len) end_len = ending
