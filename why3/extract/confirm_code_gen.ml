let gen =
  let e = ref 0 in
  let gen () =
    e := !e + 1;
    !e in
  (fun () -> gen ())
