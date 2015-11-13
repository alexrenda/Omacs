module type Interpreter = sig
    val eval_file :
      File.t -> ('a, 'b) api_function list -> Controller.callback list
end
