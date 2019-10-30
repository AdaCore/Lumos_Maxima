open All
open Format

(* TODO cannot use deriving on generated ml file *)
let print_notif fmt notif =
  match notif with
  | Got n           -> fprintf fmt "Found key: %d@." n
  | Got_failure     -> fprintf fmt "Get error: cannot find key@."
  | Add_ask n       -> fprintf fmt "Add request for key: %d@." n
  | Add_ask_failure -> fprintf fmt "Failure of add key@."
  | Added true      -> fprintf fmt "Key successfully added@."
  | Added false     -> fprintf fmt "Error: key was not added@."
  | Del_ask n       -> fprintf fmt "Del request for key: %d@." n
  | Del_failure     -> fprintf fmt "Failure of del key@."
  | Deleted true    -> fprintf fmt "Key successfully deleted@."
  | Deleted false   -> fprintf fmt "Error: key was not deleted@."

let test () =
  let state = init () in
  let n = treat_request state (Get "sylvain.dailler") in
  Format.printf "%a@." print_notif n;
  let n1 = treat_request state (Add ("sylvain.dailler", 42)) in
  Format.printf "%a@." print_notif n1;
  match n1 with
  | Add_ask n ->
    let n2 = treat_request state (Addc n) in
    Format.printf "%a@." print_notif n2;
    let n3 = treat_request state (Get "sylvain.dailler") in
    Format.printf "%a@." print_notif n3;
  | _ -> exit 1

let () = test ()
