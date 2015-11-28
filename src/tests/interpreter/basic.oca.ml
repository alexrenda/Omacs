let callback c b =
  Printf.printf "passed test\n%!";
  c, b
;;

let register_callbacks (controller:Controller.t) : Controller.t =
  let controller = Controller.register_keypress_listener
                     controller (Utils.key_of_string "C-x") callback in
  controller
;;
