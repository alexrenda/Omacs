module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
  end

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
end
