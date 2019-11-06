open Lib_test
open All

let interactive_server () =
  let state = init () in
  let buf = Bytes.create 256 in
  while true do
    try
      let a, _, _ = Unix.select [Unix.stdin] [] [] 0.2 in
      begin match a with
        | [_] ->
          let n = Unix.read Unix.stdin buf 0 256 in
          let s =  (Bytes.sub_string buf 0 (n-1)) in
          let r = parse_request s in
          let notif = treat_request state r in
          Format.printf "%a@." print_notif notif
        | [] -> () (* nothing read *)
        | _ -> assert false;
      end
    with _ -> ()
  done

let () = interactive_server ()
