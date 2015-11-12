module type Controller = sig
    type t
    type key
    type hook
    type api
    type callback = api -> unit

    val create : unit -> t

    val register_keypress_event : key -> callback -> t
    val register_hook : hook -> callback -> t

    val keypress : key -> OBuffer.t -> t
    val run_hook : hook -> OBuffer.t -> t

    val eval_file : File.t -> t
end
