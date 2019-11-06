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
  | Added false     -> fprintf fmt "Error: Add_confirm failed@."
  | Del_ask n       -> fprintf fmt "Del request for key: %d@." n
  | Del_failure     -> fprintf fmt "Failure of del key@."
  | Deleted true    -> fprintf fmt "Key successfully deleted@."
  | Deleted false   -> fprintf fmt "Error: Del_confirm failed@."

let parse_request (s: string) : request =
  let args = String.split_on_char ' ' s in
  if List.length args > 3 || List.length args < 1 then
    assert false (* TODO error *)
  else
    match args with
    | req :: email :: [] when req = "G" ->
      Get email
    | req :: email :: key :: [] when req = "A" ->
      Add (email, int_of_string key)
    | req :: key :: [] when req = "C" ->
      Addc (int_of_string key)
    | req :: email :: key :: [] when req = "D" ->
      Del (email, int_of_string key)
    | req :: key :: [] when req = "K" ->
      Delc (int_of_string key)
    | _ ->
      Format.printf "Help: \n
          G -> Get <string> \n
          A -> Add <string> <int> \n
          C -> Add confirm <int> \n
          D -> Del <string> <int> \n
          K -> Del confirm <int> \n";
      Get "" (* TODO take a real action here *)
