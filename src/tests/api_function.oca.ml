let register_callbacks (controller:Controller.t) : Controller.t =
  let s = concat_strs "hello" "world" in
  let p1 = s = "hello world" in
  let d = add_ints 4 2 in
  let p2 = d = 2 in

  let p3 = alpha_to_unit 1 = () in
  let p4 = alpha_to_unit () = () in
  let p5 = unit_to_unit () = () in
  if p1 && p2 && p3 && p4 && p5 then
    Printf.printf "passed test\n%!"
  else
    Printf.printf "failed test.\n%!";
  controller
;;
