module type Controller = sig
    type t
    type key
    type hook
    type api
    type callback = api -> unit

    val create : unit -> t

    val register_keypress_event : key -> callback -> unit
    val register_hook : hook -> callback -> unit

    val keypress : key -> OBuffer.t -> unit
    val run_hook : hook -> OBuffer.t -> unit

    val eval_file : File.t -> unit
end
