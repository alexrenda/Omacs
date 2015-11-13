type t

val create : unit -> t
val show : t -> unit
val open_file : File.t -> unit

val close : t -> unit
