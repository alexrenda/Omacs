module type Controller = sig
    type t
    type key
    type callback = key -> t -> OBuffer.t -> Terminal.t -> unit

    val register_keypress_event : callback -> unit

    val keypress : key -> OBuffer.t -> unit

    val eval_file : File.t -> unit
end
