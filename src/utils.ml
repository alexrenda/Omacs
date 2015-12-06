let (>>) f g x = g (f x)

module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
  val map : 'a t -> ('a -> 'b) -> 'b t
  val (>>|) : 'a t -> ('a -> 'b) -> 'b t
  end

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
