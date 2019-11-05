
## An experimental version of a KeyServer developed in Why3


`spec.mlw`: the specifications

`implem.mlw`: Implementation of the spec

`partial_map.mlw`: Partial maps (should be in Why3 stdlib!)

`pair_set.mlw`: Sets of pairs, implemented by an hashtabl

`simple_hashtbl.mlw`: Hashtbl with only one value for each key

`interface.mlw`: WIP, experimental, for extraction

* make doc

  produces the HTML files for the Why3 sources visible in

    `doc/index.html`

* make session

  produces the HTML dump of the proof sessions in :

    `doc/*session.html`

* make without argument: performs both make doc and make session

* make replay

  replays all the proof session

* make extract

  performs extraction to OCaml (WIP, not working yet)

* make test

  Executes the test

* make interactive

  Starts the interactive server: communication can be done on stdin/stdout
