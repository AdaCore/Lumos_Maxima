open Prelude
type 'a t = (string, 'a) Hashtbl.t

type set = (Set.t) t

type concrete_state = {
  database: set;
  confirmAdd: (int, (string * int)) Hashtbl.t;
  confirmDel: (int, (string * int)) Hashtbl.t;
  }

let create : type a. (Z.t) ->  (a t) = fun n -> Hashtbl.create (Z.to_int n)

let empty_set (_: unit) : set = create (Z.of_string "16")

let init (_: unit) : concrete_state =
  { database = empty_set (); confirmAdd =
    Hashtbl.create (Z.to_int (Z.of_string "42")); confirmDel =
    Hashtbl.create (Z.to_int (Z.of_string "42")) }

let init1 (_: unit) : concrete_state = init ()

type notif =
  | Got of int
  | Got_failure
  | Add_ask of int
  | Add_ask_failure
  | Added of bool
  | Del_ask of int
  | Del_failure
  | Deleted of bool

type request =
  | Get of string
  | Add of string * int
  | Addc of int
  | Del of string * int
  | Delc of int

let defensive_find : type a. (a t) -> (string) ->  a =
  fun h k -> defensive_find h k

let get_element (k: string) (s: set) : int =
  let sa = try defensive_find s k with
    | Not_found -> raise (Not_found) in
  if Set.is_empty sa then raise (Not_found) else Set.choose sa

let get (s: concrete_state) (e: string) : int = get_element e (s.database)

type t1 = {
  key: string;
  elt: int;
  }

let mem (e: t1) (h: set) : bool =
  try let s = defensive_find h (e.key) in Set.mem (e.elt) s with
  | Not_found -> false

exception AlreadyInDb

let add (s: concrete_state) (e: string) (k: int) : int =
  if mem ({ key = e; elt = k }) (s.database)
  then raise AlreadyInDb
  else
    begin
      let c =
        ((fun _ _ -> Confirm_code_gen.gen ()) (s.confirmAdd) (s.confirmDel)) in
      Hashtbl.add (s.confirmAdd) c ((e, k)); c end

let mem1 : type a. (a t) -> (string) ->  (bool) = fun h k -> Hashtbl.mem h k

let find : type a. (a t) -> (string) ->  a = fun h k -> Hashtbl.find h k

let replace : type a. (a t) -> (string) -> a ->  unit =
  fun h k v -> Hashtbl.replace h k v

let add1 : type a. (a t) -> (string) -> a ->  unit =
  fun h k v -> Hashtbl.add h k v

let add2 (x: t1) (s: set) : unit =
  if mem1 s (x.key)
  then
    let hs = find s (x.key) in
    let new_s = Set.add (x.elt) hs in
    replace s (x.key) new_s
  else add1 s (x.key) (Set.singleton (x.elt))

let add_c (s: concrete_state) (c: int) : bool =
  match Hashtbl.find_all (s.confirmAdd) c with
  | [] -> false
  | (e, k) :: ([]) ->
    (let t2 = { key = e; elt = k } in
     if not (mem t2 (s.database)) then add2 t2 (s.database);
     Hashtbl.remove (s.confirmAdd) c;
     true)
  | _ -> assert false (* absurd *)

exception NotInDb

let del (s: concrete_state) (e: string) (k: int) : int =
  let t2 = { key = e; elt = k } in
  if mem t2 (s.database)
  then
    let c =
      ((fun _ _ -> Confirm_code_gen.gen ()) (s.confirmAdd) (s.confirmDel)) in
    Hashtbl.add (s.confirmDel) c ((e, k)); c
  else raise NotInDb

let remove (x: t1) (s: set) : unit =
  let sa = find s (x.key) in
  let new_s = Set.remove (x.elt) sa in
  replace s (x.key) new_s

let del_c (s: concrete_state) (c: int) : bool =
  match Hashtbl.find_all (s.confirmDel) c with
  | [] -> false
  | (e, k) :: ([]) ->
    (let t2 = { key = e; elt = k } in
     if mem t2 (s.database) then remove t2 (s.database);
     Hashtbl.remove (s.confirmDel) c;
     true)
  | _ -> assert false (* absurd *)

let treat_request (s: concrete_state) (req: request) : notif =
  match req with
  | Get e ->
    begin try let o = get s e in Got o with
    | Not_found -> Got_failure
    end
  | Add (e,
    k) ->
    begin try let o = add s e k in Add_ask o with
    | AlreadyInDb -> Add_ask_failure
    end
  | Addc c -> (let o = add_c s c in Added o)
  | Del (e,
    k) ->
    begin try let o = del s e k in Del_ask o with
    | NotInDb -> Del_failure
    end
  | Delc c -> (let o = del_c s c in Deleted o)

