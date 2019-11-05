open Lib_test
open All

(* This prints the output on the stdout *)
let test req_list =
  let state = init () in
  List.iter (fun req ->
      let n = treat_request state req in
      Format.printf "%a@." print_notif n)
    req_list

let () = test [Get "sylvain.dailler";
               Add ("sylvain.dailler", 42);
               Addc 1;
               Get "sylvain.dailler";
               Add ("lumos_maxima@gmail.com", 101);
               Addc 25; (* This fails *)
               Addc 2; (* This is successful *)
               Get "lumos_maxima@gmail.com"; (* Return 101 *)
               Del ("lumos_maxima@gmail.com", 42); (* Fail *)
               Del ("lumos_maxima@gmail.com", 101);
               Delc 42; (* Fail *)
               Delc 3; (* Success *)
              ]
