let callback c b =
  Printf.printf "running callback\n%!";
  c, b
;;

let register_callbacks (controller:Controller.t) : Controller.t =
  Printf.printf "registering\n%!";
  let controller = Controller.register_keypress_event
                     controller (Controller.Char 'x') callback in
  controller
;;
