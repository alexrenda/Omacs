let passed_tests = ref (Array.make 0 false)

let register_callbacks (controller:Controller.t) : Controller.t =
  let x = Controller.Char 'x' in
  let cx = Controller.Mod (Controller.Control, x) in
  let keys_to_test = [x; cx; Controller.Chain (cx, x)] in
  passed_tests := Array.make (List.length keys_to_test) false;

  let rec register_keys controller idx = function
    | [] -> controller
    | key::t ->
       let keypress_callback c b =
         !passed_tests.(idx) <- true;
         let passed = Array.fold_left (&&) true !passed_tests in
         if passed then
           Printf.printf "passed test\n%!"
         else ();
         c, b
       in
       let controller = Controller.register_keypress_listener
                          controller key keypress_callback in
       register_keys controller (idx + 1) t
  in
  let controller = register_keys controller 0 keys_to_test in
  controller
;;
