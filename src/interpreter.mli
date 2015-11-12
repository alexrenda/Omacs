module type Interpreter = sig
    val eval_file : File.t -> Controller.callback list
end
