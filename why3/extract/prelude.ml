module OrdP =
struct
  type t = int (* Spec__Data.key *)
  let compare (a: t) (b: t) : int =
    Stdlib.compare a b

end

module Set = Set.Make (OrdP)

let defensive_find h k =
  Hashtbl.find h k

(* Confirmation code generation: TODO *)
let gen =
  let e = ref 0 in
  let gen () =
    e := !e + 1;
    !e in
  (fun () -> gen ())
