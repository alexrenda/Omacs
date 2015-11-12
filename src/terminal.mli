module type Terminal = sig
    type t

    val terminal_of_file : File.t -> t

    val show : t -> unit
    val open_file : File.file -> unit

    val close : t -> unit
end
